#include <ctime>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <map>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/thread/recursive_mutex.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/asio.hpp>
#include <boost/filesystem.hpp>
#include <boost/program_options.hpp>
#include <boost/filesystem/operations.hpp>

#include "bncsutil.h"
#include "hasher.h"
#include "wc3hasher.h"
#include "connection.h"

using boost::asio::ip::tcp;
namespace fs = boost::filesystem;
namespace po = boost::program_options;
//using boost::filesystem;
using namespace std;

void tcp_server :: start_accept()
{
	tcp_connection::pointer new_connection =
		tcp_connection::create(m_Acceptor.io_service(), this);

	m_Acceptor.async_accept(new_connection->socket(),
		boost::bind(&tcp_server::handle_accept, this, new_connection,
		boost::asio::placeholders::error));
}

void tcp_server :: handle_accept(tcp_connection::pointer new_connection,
	const boost::system::error_code& error)
{
	if(!error)
	{
		new_connection->start();
		start_accept();
	}
}

bool readfile(const fs::path &file, FileBuffer &buffer)
{
	streamsize length;
	char * fbuf;
	ifstream is;
	
	if ( !fs::exists( file ) )
	{
		std::cout << "not found: " << file << std::endl;
		return false;
	}
	
	if ( !fs::is_regular( file ) )
	{
		std::cout << "not a regular file: " << file << std::endl;
		return false;
	}
	
	is.open (file.file_string().c_str(), ios::binary );
	
	// get length of file:
	is.seekg (0, ios::end);
	length = is.tellg();
	is.seekg (0, ios::beg);
	
	
	
	streamsize buffer_size = length;
	streamsize remainder = length % 1024;
	if (remainder > 0)
	{
		buffer_size += (1024-remainder);
	}
	
	//allocate memory
	fbuf = (char *)malloc(buffer_size);
	if (!fbuf)
	{
        is.close();
		return false;
	}
	
	// read data as a block:
	is.read (fbuf, length);
	if (is.fail())
	{
		is.close();
		return false;
	}
	is.close();
	
	unsigned char padding = 0xFF;
	for(size_t i=length;i<buffer_size;i++)
	{
		*(fbuf+i) = padding--;
	}
	buffer.file_buffer = (uint8_t*)fbuf;
	buffer.buffer_size = buffer_size;
	return true;
}

int main(int argc, char *argv[])
{
	// Declare the supported options.
	po::options_description desc("Allowed options");
	desc.add_options()
    ("help", "produce help message")
	("ipv6", "enable ipv6")
    ("port", po::value<ushort>(), "set port to listen on")
	("filedir", po::value<string>(), "set directory to read files from")
	;
	
	po::variables_map vm;
	po::store(po::parse_command_line(argc, argv, desc), vm);
	po::notify(vm);    
	
	if (vm.count("help")) {
		cout << desc << endl;
		return 1;
	}

	try
	{
		boost::asio::io_service io_service;
		tcp tcp_version = tcp::v4();
		
		if (vm.count("ipv6")) {
			cout << "Using ipv6" << endl;
			tcp_version = tcp::v6();
		} else {
			cout << "Using ipv4" << endl;
		}

		ushort port = 7070;
		if (vm.count("port")) {
			port = vm["port"].as<ushort>();
			cout << "Using port " << port << endl;
		} else {
			cout << "Using default port " << port << endl;
		}

		tcp_server server(io_service, tcp_version, port);

		string filedir = "files";
		if (vm.count("filedir")) {
			filedir = vm["filedir"].as<string>();
			cout << "Using file location " << filedir << endl;
		} else {
			cout << "Using default file location " << filedir << endl;
		}

		fs::path war3file(filedir / fs::path("war3.exe"));
		fs::path gamefile(filedir / fs::path("game.dll"));
		fs::path stormfile(filedir / fs::path("Storm.dll"));
		
		if (!server.loadfiles(war3file, gamefile, stormfile))
		{
			cerr << "File loading failed, shutting down..." << endl;
			return 1;
		}

		io_service.run();
	}
	catch (std::exception& e)
	{
		std::cerr << e.what() << std::endl;
	}

	return 0;
}

bool tcp_server :: loadfiles(boost::filesystem::path war3, boost::filesystem::path game, boost::filesystem::path storm)
{
	if (!readfile(war3, m_War3ExeBuffer)) {
		cerr << "Error reading " << war3 << endl;
		return false;
	}
	char buf[64];
	unsigned int EXEVersion;
	if (getExeInfo( war3.file_string().c_str( ), (char *)&buf, 1024, &EXEVersion, BNCSUTIL_PLATFORM_X86 ) == 0)
	{
		cerr << "getExeInfo() failed for " << war3 << endl;
		return false;
	}
	m_ExeVersion = EXEVersion;
	m_ExeInfo = string( buf );
	
	cout << "Using ExeVersion " << m_ExeVersion << " with ExeInfo " << m_ExeInfo << endl;
	
	if (!readfile(game, m_GameDllBuffer)) {
		cerr << "Error reading " << game << endl;
		return false;
	}
	if (!readfile(storm, m_StormDllBuffer)) {
		cerr << "Error reading " << storm << endl;
		return false;
	}
	m_FileBuffers[0] = &m_War3ExeBuffer;
	m_FileBuffers[1] = &m_StormDllBuffer;
	m_FileBuffers[2] = &m_GameDllBuffer;
	cout << "Read all files into buffer. Size: ";
	cout << (m_War3ExeBuffer.buffer_size + m_StormDllBuffer.buffer_size + m_GameDllBuffer.buffer_size) / 1024 << " kB" << endl;
	return true;
}

string tcp_server :: generate_response(int mpqNum, const string& formula) const
{
	uint32_t EXEVersionHash = 0;
	cout << "starting checkRevisionInRam()" << endl;
	
	int errnum = checkRevisionInRam( formula.c_str( ), m_FileBuffers, 3, mpqNum, (unsigned long*)&EXEVersionHash );
	
	if (!errnum)
	{
		cerr << "checkRevisionInRam() failed" << endl;;
		return string();
	}
	
	ostringstream str;
	str << m_ExeVersion << " " << EXEVersionHash << " " << m_ExeInfo  << "\r\n";
	return str.str();
}

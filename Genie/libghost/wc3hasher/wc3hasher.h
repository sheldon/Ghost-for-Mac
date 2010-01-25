#ifndef SERVER_H
#define SERVER_H

#include <iostream>
#include <string>
#include <map>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/thread/recursive_mutex.hpp>
#include <boost/asio.hpp>
#include <boost/filesystem.hpp>

#include "connection.h"
#include "hasher.h"
using boost::asio::ip::tcp;
using namespace std;


class tcp_server
{
public:
	tcp_server(boost::asio::io_service& io_service, tcp tcp_version, ushort port)
		: m_Acceptor(io_service, tcp::endpoint(tcp_version, port))
	{
		start_accept();
	}
	bool loadfiles(boost::filesystem::path war3, boost::filesystem::path game, boost::filesystem::path storm);
	string generate_response(int mpqNum, const string& formula) const;
private:
	void start_accept();
	void handle_accept(tcp_connection::pointer new_connection, const boost::system::error_code& error);

	unsigned int m_ExeVersion;
	string m_ExeInfo;
	
	FileBuffer m_War3ExeBuffer;
	FileBuffer m_StormDllBuffer;
	FileBuffer m_GameDllBuffer;
	const FileBuffer* m_FileBuffers[3];
	tcp::acceptor m_Acceptor;
};

#endif

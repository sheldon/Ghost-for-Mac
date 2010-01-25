#include <ctime>
#include <iostream>
#include <string>
#include <vector>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/asio.hpp>
#include "bncsutil.h"

#include "connection.h"
#include "hasher.h"
#include "wc3hasher.h"

using boost::asio::ip::tcp;
using namespace std;

void tcp_connection :: start () {
	boost::asio::async_read_until(m_Socket, m_Request, "\n",
								  boost::bind(&tcp_connection::handle_read_data,
											  shared_from_this(),
											  boost::asio::placeholders::error));
}

void tcp_connection :: handle_read_data(const boost::system::error_code& err)
{
	if (!err)
	{
		std::istream request_stream(&m_Request);
		int mpqNum;
		std::string formula;
		
		request_stream >> mpqNum;
		request_stream >> ws;
			
		std::getline(request_stream, formula);
		cout << "Got request for mpqNum=" << mpqNum << " and formula " << formula << endl;
		
		m_Response = server->generate_response(mpqNum, formula);
		boost::asio::async_write(m_Socket, boost::asio::buffer(m_Response),
								 boost::bind(&tcp_connection::handle_write,
											 shared_from_this(),
											 boost::asio::placeholders::error,
											 boost::asio::placeholders::bytes_transferred));
	}
	else {
		cerr << "Read error: " << err.message() << endl;
		//disconnect();
	}

}



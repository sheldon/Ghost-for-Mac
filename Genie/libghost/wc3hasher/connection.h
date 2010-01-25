#ifndef CONNECTION_H
#define CONNECTION_H
#include <ctime>
#include <iostream>
#include <string>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/asio.hpp>

//#include "server.h"

using boost::asio::ip::tcp;
class tcp_server;

class tcp_connection
	: public boost::enable_shared_from_this<tcp_connection>
{
public:
	typedef boost::shared_ptr<tcp_connection> pointer;

	static pointer create(boost::asio::io_service& io_service, tcp_server *parent)
	{
		return pointer(new tcp_connection(io_service, parent));
	}

	tcp::socket& socket()
	{
		return m_Socket;
	}

	void start();
	void handle_read_data(const boost::system::error_code& err);

private:
	tcp_connection(boost::asio::io_service& io_service, tcp_server *parent)
		: m_Socket(io_service)
	{
		server = parent;
	}

	void handle_write(const boost::system::error_code& err,
		size_t /*bytes_transferred*/)
	{
		if (!err) {
			std::cout << "Response sent." << std::endl;
			disconnect();
		}
		else {
			std::cout << "Send error: " << err.message() << std::endl;
		}

	}
	void disconnect()
	{
		m_Socket.shutdown(tcp::socket::shutdown_both);
		m_Socket.close();
	}

	tcp::socket m_Socket;
	boost::asio::streambuf m_Request;
	std::string m_Response;

	tcp_server *server;
};
#endif

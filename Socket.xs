#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <sys/socket.h>
#include <sys/param.h>
#include <sys/time.h>

#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/l2cap.h>
#include <bluetooth/rfcomm.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

#define CHECK_CHAN(c) ((c<1 || c>30) ? 0:1);

int
int_bind(int socket, char *address)
{
  struct sockaddr_rc sa;

  if (socket > 0) {

/* use alway ANY fow now*/

        bacpy(&sa.rc_bdaddr, BDADDR_ANY);
	sa.rc_channel = 0;

        if (bind(socket, (struct sockaddr *) &sa, sizeof(sa)) < 0) {
            return -1;
	}
  } else {
	return -2;
  }
}
		

MODULE = Bluetooth::Socket		PACKAGE = Bluetooth::Socket		

PROTOTYPES: ENABLE

int 
i_socket(domain,type,proto)
	int domain;
	int type;
	int proto;
	CODE:
		RETVAL = socket(domain, type, proto);
	OUTPUT:
	RETVAL

int
i_bind(sock, address)
	int sock;
	char *address;
	CODE:
	   RETVAL = int_bind(sock, address);
	OUTPUT:
	RETVAL

int
i_connect(sock,address,channel)
	int sock;
	char *address;
	int channel;
	PREINIT:
	struct sockaddr_rc sa;
	bdaddr_t dst;
	int resp;
	CODE:
		if (sock > 0) {
	                str2ba(address, &dst);
			sa.rc_family  = AF_BLUETOOTH;
			sa.rc_channel = channel;
                        bacpy(&sa.rc_bdaddr, &dst);
			if ((resp = connect(sock, (struct sockaddr *) &sa, sizeof(sa))) < 0) {
				fprintf(stderr,"Can't connect. %s\n", strerror(errno));
			}

	                RETVAL = resp;

		} else {
		   croak("connect() : Wrong Socket");
		}
	OUTPUT:
	RETVAL

int
i_close(socket)
	int socket;
	CODE:
		RETVAL = close(socket);
	OUTPUT:
	RETVAL

int i_write(socket, data, len, debug)
	int socket;
	char *data;
	int len;
	int debug;
	CODE:
	int actual = 0;
        int pos = 0;

	while (actual < len) {
		int frag = 0;
                frag = write(socket, &data[pos], len - pos);
		if (frag < 0) {
                        if (errno == EAGAIN) {
                                frag = 0;
				croak("No resource available");
                        } else {
				croak("write() %s", strerror(errno));
                        }
                }
         
	        actual += frag;
                pos += frag;

		if (debug)
                 printf("Wrote %d fragment", frag);
	}

        if (debug)
         printf("Wrote %d bytes (expected %d)", actual, len);
        
        RETVAL = actual;
	OUTPUT:
	RETVAL

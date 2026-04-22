#include <stdio.h>      /* standard C i/o facilities */
#include <stdlib.h>     /* needed for atoi() */
#include <unistd.h>  	/* defines STDIN_FILENO, system calls,etc */
#include <sys/types.h>  /* system data type definitions */
#include <sys/socket.h> /* socket specific definitions */
#include <sys/stat.h>
#include <netinet/in.h> /* INET constants and stuff */
#include <arpa/inet.h>  /* IP address conversion stuff */
#include <netdb.h>	    /* gethostbyname */
#include <string.h>
#include <fcntl.h>
#include <syslog.h>
#include <errno.h>
#include <pwd.h>
#include <signal.h>


#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

#include "crc.h"
#include "FSPacket.h"

/* Change this to whatever your daemon is called */
#define DAEMON_NAME "flatsun"

/* Change this to the user under which to run */
#define RUN_AS_USER "root"


#define UDP_PORT    12399

#define MAXBUF 1024*1024

FILE *      FlatSun;
FSPacket *  Packets[FS_COLUMNS];

void    Packet_SetCRC(DisplayPacket * packet)
{
    uint32_t CRCValue = 0xFFFFFFFF;
    int     packet_size = (sizeof(DisplayPacket) - sizeof(uint32_t));

    CRCValue = CRC32WideFast(CRCValue, packet_size, (uint8_t *) packet);

    packet->crc = CRCValue;
}

void sync_data()
{
    int row, col;
    unsigned int bt;
    unsigned short data[FS_ROWS];

    for (col = 0; col < FS_COLUMNS; col ++) {
        for (row = 0; row < FS_ROWS; row ++) {
            data[row] = 0x100 | Packets[col][row].panel_col;
        }
        if (FlatSun) fwrite(data,sizeof(unsigned short),FS_ROWS,FlatSun);

        for (bt = 0; bt < sizeof(struct DisplayPacket); bt ++ ) {
            for (row = 0; row < FS_ROWS; row ++) {
                unsigned char * dp = (unsigned char *) &Packets[col][row].display_packet;
                data[row] = dp[bt];
            }
            if (FlatSun) fwrite(data,sizeof(unsigned short),FS_ROWS,FlatSun);
        }
    }
}

void echo( int sd ) {
    socklen_t len;
    int n;
    char bufin[MAXBUF];
    struct sockaddr_in remote;

    /* need to know how big address struct is, len must be set before the
       call to recvfrom!!! */

    len = sizeof(remote);
    
    syslog( LOG_INFO, "Listening" );

    while (1) {
        /* read a datagram from the socket (put result in bufin) */
        n=recvfrom(sd, (void *) bufin,MAXBUF,0,(struct sockaddr *)&remote,&len);

        /* print out the address of the sender */
        // printf("Got a datagram from %s port %d\n",     inet_ntoa(remote.sin_addr), ntohs(remote.sin_port));

        if (n<0) {
            perror("Error receiving data");
        } else {
            // printf("GOT %d BYTES\n",n);

            if (n == sizeof(FSPacketData)) {
                FSPacket * packet = (FSPacket *) bufin;
                // fprintf(stderr, "Type = %d\n", packet->type);
                if (packet->type == FS_TYPE_DATA) {
                    // fprintf(stderr, "%d%d ", packet->panel_row, packet->panel_col);
                    Packet_SetCRC(&(packet->display_packet));
                    memcpy(&Packets[packet->panel_col][packet->panel_row], packet, sizeof(FSPacket));
                } else {
                    fprintf(stderr, ".");
                    sync_data();
                }
            }
        }
    }
}


static void child_handler(int signum)
{
    switch(signum) {
    case SIGALRM: exit(EXIT_FAILURE); break;
    case SIGUSR1: exit(EXIT_SUCCESS); break;
    case SIGCHLD: exit(EXIT_FAILURE); break;
    }
}

static void daemonize( const char *lockfile )
{
    pid_t pid, sid, parent;
    int lfp = -1;

    syslog( LOG_INFO, "pass 0" );

    /* already a daemon */
    // if ( getppid() == 1 ) return;

    /* Create the lock file as the current user */
    if ( lockfile && lockfile[0] ) {
        lfp = open(lockfile,O_RDWR|O_CREAT,0640);
        if ( lfp < 0 ) {
            fprintf( stderr, "unable to create lock file %s, code=%d (%s)",
                    lockfile, errno, strerror(errno) );
            syslog( LOG_ERR, "unable to create lock file %s, code=%d (%s)",
                    lockfile, errno, strerror(errno) );
            exit(EXIT_FAILURE);
        }
    }
    syslog( LOG_INFO, "pass 1" );

#if 0
    /* Drop user if there is one, and we were run as root */
    if ( getuid() == 0 || geteuid() == 0 ) {
        struct passwd *pw = getpwnam(RUN_AS_USER);
        if ( pw ) {
            syslog( LOG_NOTICE, "setting user to " RUN_AS_USER );
            setuid( pw->pw_uid );
        }
    }
#endif

    /* Trap signals that we expect to recieve */
    signal(SIGCHLD,child_handler);
    signal(SIGUSR1,child_handler);
    signal(SIGALRM,child_handler);

    /* Fork off the parent process */
    pid = fork();
    if (pid < 0) {
        fprintf(stderr, "unable to fork daemon, code=%d (%s)",
                errno, strerror(errno) );
        syslog( LOG_ERR, "unable to fork daemon, code=%d (%s)",
                errno, strerror(errno) );
        exit(EXIT_FAILURE);
    }
    /* If we got a good PID, then we can exit the parent process. */
    if (pid > 0) {

        /* Wait for confirmation from the child via SIGTERM or SIGCHLD, or
           for two seconds to elapse (SIGALRM).  pause() should not return. */
        alarm(2);
        pause();

        exit(EXIT_FAILURE);
    }

    /* At this point we are executing as the child process */
    parent = getppid();

    /* Cancel certain signals */
    signal(SIGCHLD,SIG_DFL); /* A child process dies */
    signal(SIGTSTP,SIG_IGN); /* Various TTY signals */
    signal(SIGTTOU,SIG_IGN);
    signal(SIGTTIN,SIG_IGN);
    signal(SIGHUP, SIG_IGN); /* Ignore hangup signal */
    signal(SIGTERM,SIG_DFL); /* Die on SIGTERM */

    /* Change the file mode mask */
    umask(0);

    /* Create a new SID for the child process */
    sid = setsid();
    if (sid < 0) {
        syslog( LOG_ERR, "unable to create a new session, code %d (%s)",
                errno, strerror(errno) );
        exit(EXIT_FAILURE);
    }

    /* Change the current working directory.  This prevents the current
       directory from being locked; hence not being able to remove it. */
    if ((chdir("/")) < 0) {
        syslog( LOG_ERR, "unable to change directory to %s, code %d (%s)",
                "/", errno, strerror(errno) );
        exit(EXIT_FAILURE);
    }

    /* Redirect standard files to /dev/null */
    freopen( "/dev/null", "r", stdin);
    freopen( "/dev/null", "w", stdout);
    freopen( "/dev/null", "w", stderr);

    /* Tell the parent process that we are A-okay */
    kill( parent, SIGUSR1 );
}


/* server main routine */

int main() {
    int ld;
    struct sockaddr_in skaddr;
    int i;
    socklen_t length;
    char dummy;

    /* Initialize the logging interface */

    openlog( DAEMON_NAME, LOG_PID, LOG_LOCAL5 );
    syslog( LOG_INFO, "starting" );

    /* One may wish to process command line arguments here */

    /* Daemonize */
    // fprintf(stderr, "Starting as daemon\n");
    daemonize( "/var/lock/" DAEMON_NAME );
    // fprintf(stderr, "Running as daemon\n");
    syslog( LOG_INFO, "as daemon" );

 
    /* Opening the device parlelport */
    FlatSun=fopen("/dev/flatsun","w");

    if (FlatSun == NULL) {
         // syslog( LOG_INFO, "Unable to open FlatSun device" );
        // fprintf(stderr, "Unable to open FlatSun device\n");
        // return -1;
    } else {
        /* We remove the buffer from the file i/o */
        setvbuf(FlatSun,&dummy,_IONBF,1);
        syslog( LOG_INFO, "FlatSun Device opened" );
        // fprintf(stderr, "FlatSun Device opened\n");
    }

    for (i=0; i<FS_COLUMNS; i++) {
        Packets[i] = (FSPacket *) calloc(sizeof(FSPacket), FS_ROWS);
    }

    if ((ld = socket( PF_INET, SOCK_DGRAM, 0 )) < 0) {
         syslog( LOG_INFO, "Problem creating socket" );
        // printf("Problem creating socket\n");
        exit(1);
    }

    skaddr.sin_family = AF_INET;
    skaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    skaddr.sin_port = htons(UDP_PORT);

    if (bind(ld, (struct sockaddr *) &skaddr, sizeof(skaddr))<0) {
        syslog( LOG_INFO, "Problem binding" );
        // printf("Problem binding\n");
        exit(0);
    }

    /* find out what port we were assigned and print it out */

    length = sizeof( skaddr );
    if (getsockname(ld, (struct sockaddr *) &skaddr, &length)<0) {
        syslog( LOG_INFO, "Error getsockname" );
        // printf("Error getsockname\n");
        exit(1);
    }

    /* port number's are network byte order, we have to convert to
       host byte order before printing !
     */
    syslog( LOG_INFO, "The server UDP port number is %d\n",ntohs(skaddr.sin_port));

    /* Go echo every datagram we get */
    echo(ld);
    return(0);
}

/**
 * The flatsun module from Ch#2 of Linux Device Driver 3rd Ed
 */
#include <asm/io.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>   /* printk() */
#include <linux/slab.h>     /* kmalloc() */
#include <linux/fs.h>       /* everything... */
#include <linux/errno.h>    /* error codes */
#include <linux/types.h>    /* size_t */
#include <linux/proc_fs.h>
#include <linux/fcntl.h>    /* O_ACCMODE */
#include <asm/system.h>     /* cli(), *_flags */
#include <asm/uaccess.h>    /* copy_from/to_user */

#define MAJOR_VERSION   1
#define MINOR_VERSION   0

/* Declaration of memory.c functions */
int flatsun_open(struct inode *inode, struct file *filp);
int flatsun_release(struct inode *inode, struct file *filp);
ssize_t flatsun_read(struct file *filp, char *buf, size_t count, loff_t *f_pos);
ssize_t flatsun_write(struct file *filp, const char *buf, size_t count, loff_t *f_pos);
int flatsun_ioctl(struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg);

#define DIO_BASE        0xe8000000

#define PANEL_COUNT     12  /* Maximum panel drivers */
#define SPI_CLK         (1 << 15)
#define DATA_DIR        (1 << 30)   /* 1 : write to panels, 0 : read from panels */

#define DELAY           17  /* 2250000  bps */

/* Structure that declares the usual file */
/* access functions */
struct file_operations flatsun_fops = {
      read: flatsun_read,
      write: flatsun_write,
      ioctl: flatsun_ioctl,
      open: flatsun_open,
      release: flatsun_release
};

struct flatsun_info {
    void __iomem    * BASE_MEM;     /* DIO Base */
    void __iomem    * PORT_DATA;    /* Port A Data address */
    void __iomem    * PORT_DIR;     /* Port A IO Direction */
    void __iomem    * PORT_FUNC;    /* Port A Function -> DIO */
    void __iomem    * PORT_LED;    /* Port A Function -> DIO */
    unsigned int    frame_size;
    unsigned int    delay;
};

static struct flatsun_info * fsinfo = NULL;

/* Global variables of the driver */
/* Major number */
int flatsun_major = 60;

int flatsun_open(struct inode *inode, struct file *filp) 
{
    printk("<1>FlatSun driver opened\n"); 
    
    /* Success */
    /* Switch on the led */
    * ((unsigned int *) fsinfo->PORT_LED) |= (1 << 31);
    return 0;
}


int flatsun_release(struct inode *inode, struct file *filp) 
{
    printk("<1>FlatSun driver released\n"); 
    /* Switch off the led */
    * ((unsigned int *) fsinfo->PORT_LED) &= ~(1 << 31);
    /* Success */
    return 0;
}

ssize_t flatsun_read(struct file *filp, char *buf, size_t count, loff_t *f_pos) 
{ 
    /* Transfering data to user space */ 
    return 0;
}

ssize_t flatsun_write( struct file *filp, const char *buf, size_t count, loff_t *f_pos) 
{
    unsigned int mc0;
    unsigned short bit;
    unsigned int mask;
    int i, p;
    volatile int k;
    unsigned short panels[PANEL_COUNT];
    unsigned int   words[32];
    unsigned int * ptr;
    int panel_count;

    int to_copy = count;

    /* Don't write more than the number of panels available */
    if ((to_copy / sizeof(short)) > PANEL_COUNT) {
        to_copy = PANEL_COUNT * sizeof(short);
    }
    panel_count = to_copy / 2;

    // printk("<1>flatsun_write, writing  : 0x%04x bytes, copying %d bytes\n", count, to_copy); 
    copy_from_user((char *) panels,buf,to_copy);

    ptr = words;
    * ptr ++ = DATA_DIR | 0xFFF;		/* Start bit  - 12 ports */
    for (i=fsinfo->frame_size - 1, bit=0x1; i >= 0; i--, bit <<=1) {
        mc0 = 0;
        for (p=panel_count - 1; p >= 0; p--) {
            mask = 1 << p;
            if ((panels[p] & bit) == 0) mc0 |= mask;
        }
        * ptr ++ = DATA_DIR | mc0;
    }     
    * ptr ++ = DATA_DIR;	/* Stop bit */

    ptr = words;
    /* Critical timing loop - bitbanging serial data to all panels */
    local_irq_disable();
    for (i=fsinfo->frame_size + 1; i >= 0; i--) {
        for (k=0; k<DELAY; k++);
        * ((unsigned int *) fsinfo->PORT_DATA) = * ptr++;
    }
    local_irq_enable();

    return count;
}

int flatsun_ioctl(struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg)
{
    return 0;
}


static void __exit flatsun_exit(void) {
    /* Freeing the major number */
    unregister_chrdev(flatsun_major, "flatsun");

    if (fsinfo) {
        iounmap((void *) fsinfo->BASE_MEM);
        kfree(fsinfo);
    }

    printk("<1>Removing FlatSun module V%d.%d\n", MAJOR_VERSION, MINOR_VERSION); 
}



static int __init flatsun_init(void) {
    int result;
    char * diomem;

    /* Registering device */
    result = register_chrdev(flatsun_major, "flatsun", &flatsun_fops);
    if (result < 0) {
        printk("<1>memory: cannot obtain major number %d\n", flatsun_major);
        return result;
    }


    fsinfo = kmalloc(sizeof(struct flatsun_info), GFP_KERNEL);
    if (!fsinfo) {
        printk("<1>Unable to allocate FlatSun Memory\n");
        result =  -ENOMEM;
        goto fail;
    }
    memset((char *) fsinfo, 0, sizeof(struct flatsun_info));

    diomem = ioremap(DIO_BASE, 0x1000);

    fsinfo->BASE_MEM  = diomem;
    fsinfo->PORT_DATA = diomem + 0x10;
    fsinfo->PORT_DIR  = diomem + 0x20;
    fsinfo->PORT_FUNC = diomem + 0x30;
    fsinfo->PORT_LED  = diomem + 0x08;
    fsinfo->frame_size = 9;

    * ((unsigned int *) fsinfo->PORT_FUNC) = 0;
    * ((unsigned int *) fsinfo->PORT_DIR) = 0xFFFFFFFF;


    printk("<1>Inserting FlatSun module V%d.%d, delay = %d\n", MAJOR_VERSION, MINOR_VERSION, DELAY); 
    return 0;

fail: 
    flatsun_exit(); 
    return result;
}


module_init(flatsun_init);
module_exit(flatsun_exit);

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("gideon@computer.org");
MODULE_DESCRIPTION("Flat Sun Driver");

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>

static int __init hello_init(void) {
  printk(KERN_INFO "Hello Hacker: You are now at Ring 1!\n");
  return 0; // 0 means success
}

static void __exit hello_exit(void) {
  printk(KERN_INFO "Goodbye Hacker: Leaving Ring 1.\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("rtarway");
MODULE_DESCRIPTION("A simple beginner hacker module");
obj-m += hello.o

all:
	mkdir -p ../../bin/hello-hacker
	make -C /home/hacker/workspace/linux M=$(shell pwd) modules
	mv *.ko *.mod.c *.o modules.order Module.symvers ../../bin/hello-hacker/
	rm -f .*.cmd .tmp_versions

clean:
	make -C /home/hacker/workspace/linux M=$(shell pwd) clean
	rm -rf ../../bin/hello-hacker
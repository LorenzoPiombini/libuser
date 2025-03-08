TARGET = user_manager
SRC = $(wildcard src/*.c)
OBJ = $(patsubst src/%.c, obj/%.o, $(SRC))
OBJ_PROD = $(patsubst src/%.c, obj/%_prod.o, $(SRC))
OBJlibuser = obj/uniuser.o
OBJlibuserPR = obj/uniuser_prod.o

LIBNAMEuser = uniuser
LIBDIR = /usr/local/lib
INCLUDEDIR = /usr/local/include
SHAREDLIBuser = lib$(LIBNAMEuser).so

default:$(TARGET)

prod:$(TARGET)_prod

clean:
	sudo rm -r obj/*.o
	rm *$(TARGET)*
	rm -f $(INCLUDEDIR)/uniuser.h
	rm -f $(LIBDIR)/$(LIBNAMEuser)
	rm -f config.log
	rm -f config.status
	sudo rm -f $(SHAREDLIBuser) 

object-dir:
	@if [ ! -d ./obj ]; then\
		echo "creating obj directory..." ;\
		mkdir obj ;\
	fi

check-linker-path:                                                                                                
	@if [ ! -f /etc/ld.so.conf.d/customtech.conf ]; then \
        echo "setting linker configuration..." ;\
        echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/customtech.conf >/dev/null ;\
		sudo ldconfig;\
	fi
mv-config.h:
	@if [ -f ./config.h ]; then\
		mv config.h ./include ;\
	fi

library:
	sudo gcc -Wall -fPIC -shared -o $(SHAREDLIBuser) $(OBJlibuser)
		
libraryPR:
	sudo gcc -Wall -fPIC -shared -o $(SHAREDLIBuser) $(OBJlibuserPR)

$(TARGET):$(OBJ)
	@if [ "0" = "1" ]; then\
		gcc -o $@ $? -lcrypt -lstrOP -fsanitize=address -pie -z relro -z now -z noexecstack ;\
	else\
		gcc -o $@ $? -lcrypt -fsanitize=address -pie -z relro -z now -z noexecstack ;\
	fi

obj/%.o:src/%.c
	gcc -Wall -g3 -c $< -o $@ -Iinclude -fstack-protector-strong -D_FORTiFY_SOURCE=2 -fPIC -fsanitize=address

$(TARGET)_prod:$(OBJ_PROD)
	@if [ "0" = "1" ]; then\
		gcc -o $@ $? -lcrypt -lstrOP -pie -z relro -z now -z noexecstack ;\
	else\
		gcc -o $@ $? -lcrypt  -pie -z relro -z now -z noexecstack ;\
	fi

obj/%_prod.o:src/%.c
	gcc -Wall -c $< -o $@ -Iinclude -fstack-protector-strong -D_FORTiFY_SOURCE=2 -fPIC 



install:
	install -d $(INCLUDEDIR)
	install -m 644 include/uniuser.h $(INCLUDEDIR)
	install -m 755 $(SHAREDLIBuser) $(LIBDIR)
	ldconfig

build:mv-config.h object-dir default library check-linker-path install

build_prod:mv-config.h object-dir prod libraryPR check-linker-path install

.PHONY: install object-dir default library check-linker-path mv-config.h 

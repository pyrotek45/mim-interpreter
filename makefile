make:
	fpc -omim main_modul.pas 
	cp mim /usr/bin
clean:
	rm mim
	rm /usr/bin/mim

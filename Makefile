POSEDIR=$(HOME)/stuff/x86/pose-3.5

CP=cp
RM=rm
OBJ=OverbitePalm.prc
POSE=$(HOME)/src/qemu-5.2.0/build/qemu-i386 -L $(HOME)/mnt $(POSEDIR)/pose
PLUA2C=plua2c
PILOT-XFER=pilot-xfer

default: $(OBJ)

.PHONY: clean run xfer

$(OBJ): overbite.lua
	$(PLUA2C) -o $@ -name "Overbite" -cid "ovRb" $<

clean:
	$(RM) -f $(OBJ)

run: $(OBJ)
	$(POSE) -load_apps $(OBJ)

xfer: $(OBJ)
	$(PILOT-XFER) -p usb: -i $(OBJ)


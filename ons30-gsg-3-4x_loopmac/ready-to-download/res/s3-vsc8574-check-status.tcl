################################################################################
### STEP 1: check config/status reg.
################################################################################
# get pcs/pma Reg 0 (config)
# def. 0x1540, good 0x1140
mw 43c00504 05008800; sleep 1; md 43c00500 4;
mw 43c40504 05008800; sleep 1; md 43c40500 4;
mw 43c80504 05008800; sleep 1; md 43c80500 4;
mw 43cc0504 05008800; sleep 1; md 43cc0500 4;

# get vsc8574 Reg 0 (config)
# def. 0x1040, good 0x1140
mw 43c00504 10008800; sleep 1; md 43c00500 4;
mw 43c00504 11008800; sleep 1; md 43c00500 4;
mw 43c00504 12008800; sleep 1; md 43c00500 4;
mw 43c00504 13008800; sleep 1; md 43c00500 4;

# get pcs/pma Reg 1 (status)
# def. 0x01c8, good 0x01ec, latch 0x01f8|0x01e8
mw 43c00504 05018800; sleep 1; md 43c00500 4;
mw 43c40504 05018800; sleep 1; md 43c40500 4;
mw 43c80504 05018800; sleep 1; md 43c80500 4;
mw 43cc0504 05018800; sleep 1; md 43cc0500 4;

# get vsc8574 Reg 1 (status)
# def. 0x79c9, good 0x79ed
mw 43c00504 10018800; sleep 1; md 43c00500 4;
mw 43c00504 11018800; sleep 1; md 43c00500 4;
mw 43c00504 12018800; sleep 1; md 43c00500 4;
mw 43c00504 13018800; sleep 1; md 43c00500 4;

################################################################################
### STEP 2: check AN reg.
################################################################################
# get pcs/pma Reg 4 (AN ADV)
# always 0x0001
mw 43c00504 05048800; sleep 1; md 43c00500 4;
mw 43c40504 05048800; sleep 1; md 43c40500 4;
mw 43c80504 05048800; sleep 1; md 43c80500 4;
mw 43cc0504 05048800; sleep 1; md 43cc0500 4;

# get vsc8574 Reg 4 (AN ADV)
# def. 0x01e1, good 0x01e1
mw 43c00504 10048800; sleep 1; md 43c00500 4;
mw 43c00504 11048800; sleep 1; md 43c00500 4;
mw 43c00504 12048800; sleep 1; md 43c00500 4;
mw 43c00504 13048800; sleep 1; md 43c00500 4;

# get pcs/pma Reg 5 (AN LP)
# def. 0x0001, good 0x5801(should be 0xd801)
mw 43c00504 05058800; sleep 1; md 43c00500 4;
mw 43c40504 05058800; sleep 1; md 43c40500 4;
mw 43c80504 05058800; sleep 1; md 43c80500 4;
mw 43cc0504 05058800; sleep 1; md 43cc0500 4;

# get vsc8574 Reg 5 (AN LP)
# def. 0x0000, good 0xcde1
mw 43c00504 10058800; sleep 1; md 43c00500 4;
mw 43c00504 11058800; sleep 1; md 43c00500 4;
mw 43c00504 12058800; sleep 1; md 43c00500 4;
mw 43c00504 13058800; sleep 1; md 43c00500 4;
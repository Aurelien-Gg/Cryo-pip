
nano ~/.bashrc

export PATH="/work/FAC/FBM/DMF/pnavarr1/default/CryoSPARC/cryosparc_master/bin:$PATH"

This way you can directly type ```cryosparcm start```

Alternatively you can start CryoSPARC using the full path of where it's located:
/work/FAC/FBM/DMF/pnavarr1/default/CryoSPARC/cryosparc_master/cryosparcm start

Don't forget to close CryoSPARC once finished:
cryosparcm stop
(or with full path: /work/FAC/FBM/DMF/pnavarr1/default/CryoSPARC/cryosparc_master/cryosparcm stop )

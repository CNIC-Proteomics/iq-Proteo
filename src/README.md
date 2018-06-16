# Adaptors

## Under construction

Desribes the scripts.


## SanXoT (integrator)

Checkout the current version from the SVN repository
```bash
svn co svn://aitne.cnic.es/proteomica/integrador/tags/current SanXoT
```


## pRatio

Temporal!!:
For the moment, we extract the columns you need using **aljamia** program:

```bash
set BaseFolder=D:\data\Edema_Oxidation_timecourse_Cys_pig\PTMs
set Data=ID-q_Comet_out_orphans-56_labeled.txt

:: ALJAMIA SData -----------------
aljamia.exe -x"~/test/test_for_corrector/ID-q.txt" -p"" -o"~/test/test_for_corrector/ID-q.Seq-Prot-Redun.txt" -i"[Raw_FirstScan]-[Charge]" -j"[Xs_%%i_126]" -k"[Vs_%%i_126]" -l"PTM" -f"[Modified]== TRUE" -R1
```

## Corrector

Selects the best protein from a list of peptides


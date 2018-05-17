import pandas
import pprint

# Config variables for workflow
CONF_WORKFLOW       = config["workflow"]
WF_PRESANXOT2  = CONF_WORKFLOW["presanxot2"]
PRESANXOT2_SRC = WF_PRESANXOT2["src"]

# Config variables from the input data
PARAMS = {}

def infiles(ifile):
    '''
    Handles the input data
    '''
    indata = pandas.read_excel(ifile)
    for idx, indat in indata.iterrows():
        msf = indat["msf"]
        PARAMS[msf] = {}
        PARAMS[msf]["wksdir"]      = indat["wksdir"]
        PARAMS[msf]["outdir"]      = indat["outdir"]
        PARAMS[msf]["tags"]        = indat["tags"]
        PARAMS[msf]["control_tag"] = indat["control_tag"]
        PARAMS[msf]["first_tag"]   = indat["first_tag"]
        if WF_PRESANXOT2["create_qall"]["enabled"]:
            yield "{outdir}/{msf}/Q-all.csv".format(outdir=indat["outdir"], msf=msf)
        if WF_PRESANXOT2["create_idq"]["enabled"]:
            yield "{outdir}/{msf}/ID-q.txt".format(outdir=indat["outdir"], msf=msf)

rule all:
    '''
    Config the output files
    '''
    input:
        infiles(config["indata"])

if WF_PRESANXOT2["create_qall"]["enabled"]:   
    rule create_qall:
        '''
        Create the Q-all from the MSF information of PD
        '''
        threads: 8
        message: "Executing create_qall with {threads} threads"
        input:
            msfdir = lambda wc: PARAMS[wc.msf]["wksdir"] +"/"+ wc.msf
        params:
            tags = lambda wc: PARAMS[wc.msf]["tags"]
        output:
            qallfile = "{outdir}/{msf}/Q-all.csv"
        log:
            "{outdir}/{msf}/presanxot2.log"
        shell:
            "Rscript --vanilla {PRESANXOT2_SRC}/create_q-all.R \
                --indir {input.msfdir} \
                --tags  {params.tags} \
                --outfile {output.qallfile} >> {log}"

if WF_PRESANXOT2["create_idq"]["enabled"]:
    rule create_idq:
        '''
        Create the ID-Q output file
        '''
        threads: 8
        message: "Executing 'create_idq' with {threads} threads"
        input:
            idenfile = lambda wc: PARAMS[wc.msf]["wksdir"] +"/"+ wc.msf +"/ID-all.txt",
            qallfile = lambda wc: PARAMS[wc.msf]["outdir"] +"/"+ wc.msf +"/Q-all.csv" if WF_PRESANXOT2["create_qall"]["enabled"] else PARAMS[wc.msf]["wksdir"] +"/"+ wc.msf +"/Q-all.csv"
        params:
            tags         = lambda wc: PARAMS[wc.msf]["tags"],
            control_tag  = lambda wc: PARAMS[wc.msf]["control_tag"],
            first_tag    = lambda wc: PARAMS[wc.msf]["first_tag"],
            mean_calc    = WF_PRESANXOT2["create_idq"]["mean_calc"],
            mean_tags    = WF_PRESANXOT2["create_idq"]["mean_tags"],
            abs_calc     = WF_PRESANXOT2["create_idq"]["abs_calc"],
            comparatives = WF_PRESANXOT2["create_idq"]["comparatives"],
            random       = WF_PRESANXOT2["create_idq"]["random"],
            filt_orphans = WF_PRESANXOT2["create_idq"]["filt_orphans"],
            no_mod_mass  = WF_PRESANXOT2["create_idq"]["no_mod_mass"]
        output:
            idqfile = "{outdir}/{msf}/ID-q.txt"
        log:
            "{outdir}/{msf}/presanxot2.log"
        shell:
            "Rscript --vanilla {PRESANXOT2_SRC}/create_id-q.R \
                --in_ident {input.idenfile} \
                --in_quant {input.qallfile} \
                --tags  {params.tags} \
                --control_tag  {params.control_tag} \
                --first_tag  {params.first_tag} \
                --mean_calc  {params.mean_calc} \
                --mean_tags  {params.mean_tags} \
                --abs_calc  {params.abs_calc} \
                --comparatives  {params.comparatives} \
                --random  {params.random} \
                --filt_orphans  {params.filt_orphans} \
                --no_mod_mass {params.no_mod_mass} \
                --outfile {output.idqfile} >> {log}"

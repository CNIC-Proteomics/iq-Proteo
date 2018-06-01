import pandas
import pprint

# Config variables for workflow
WF_NAME = "presanxot2"
WF_IDAT = config["indata"]
WF_CONF = config["workflow"]
WF_HOME = WF_CONF["presanxot2"]
WF_SRC  = WF_HOME["src"]

# Config variables from the input data
PARAMS = {}

# Indicate the output files
def infiles(ifile):
    '''
    Handles the input data
    '''
    indata = pandas.read_excel(ifile)
    for idx, indat in indata.iterrows():
        exp = indat["experiment"]
        PARAMS[exp] = {}
        PARAMS[exp]["wksdir"]      = indat["wksdir"]
        PARAMS[exp]["outdir"]      = indat["outdir"]
        PARAMS[exp]["tags"]        = indat["tags"]
        PARAMS[exp]["control_tag"] = indat["control_tag"]
        PARAMS[exp]["first_tag"]   = indat["first_tag"]
        if WF_HOME["create_qall"]["enabled"]:
            yield "{outdir}/{wfname}/{exp}/Q-all.csv".format(outdir=indat["outdir"], wfname=WF_NAME, exp=exp)
        if WF_HOME["create_idq"]["enabled"]:
            yield "{outdir}/{wfname}/{exp}/ID-q.txt".format(outdir=indat["outdir"], wfname=WF_NAME, exp=exp)

rule all:
    '''
    Config the output files
    '''
    input:
        infiles(config["indata"])

if WF_HOME["create_qall"]["enabled"]:   
    rule create_qall:
        '''
        Create the Q-all from the MSF information of PD
        '''
        threads: 1
        message: "Executing 'create_qall' with {threads} threads for {wildcards.exp}"
        input:
            msfdir = lambda wc: PARAMS[wc.exp]["wksdir"] +"/"+ wc.exp
        params:
            tags = lambda wc: PARAMS[wc.exp]["tags"]
        output:
            qallfile = "{outdir}/{wfname}/{exp}/Q-all.csv"
        log:
            "{outdir}/{wfname}/{exp}/presanxot2.log"
        shell:
            "Rscript --vanilla {WF_SRC}/create_q-all.R \
                --indir {input.msfdir} \
                --tags  {params.tags} \
                --outfile {output.qallfile} >> {log}"

if WF_HOME["create_idq"]["enabled"]:
    rule create_idq:
        '''
        Create the ID-Q output file
        '''
        threads: 1
        message: "Executing 'create_idq' with {threads} threads for {wildcards.exp}"
        input:
            idenfile = lambda wc: PARAMS[wc.exp]["wksdir"] +"/"+ wc.exp +"/ID-all.txt",
            qallfile = lambda wc: PARAMS[wc.exp]["outdir"] +"/"+ wc.exp +"/Q-all.csv" if WF_HOME["create_qall"]["enabled"] else PARAMS[wc.exp]["wksdir"] +"/"+ wc.exp +"/Q-all.csv"
        params:
            tags         = lambda wc: PARAMS[wc.exp]["tags"],
            control_tag  = lambda wc: PARAMS[wc.exp]["control_tag"],
            first_tag    = lambda wc: PARAMS[wc.exp]["first_tag"],
            mean_calc    = WF_HOME["create_idq"]["mean_calc"],
            mean_tags    = WF_HOME["create_idq"]["mean_tags"],
            abs_calc     = WF_HOME["create_idq"]["abs_calc"],
            comparatives = WF_HOME["create_idq"]["comparatives"],
            random       = WF_HOME["create_idq"]["random"],
            filt_orphans = WF_HOME["create_idq"]["filt_orphans"],
            no_mod_mass  = WF_HOME["create_idq"]["no_mod_mass"]
        output:
            idqfile = "{outdir}/{wfname}/{exp}/ID-q.txt"
        log:
            "{outdir}/{wfname}/{exp}/presanxot2.log"
        shell:
            "Rscript --vanilla {WF_SRC}/create_id-q.R \
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

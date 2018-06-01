import pandas
import pprint

# Config variables for workflow
WF_NAME = "sanxot"
WF_IDAT = config["indata"]
WF_CONF = config["workflow"]
WF_HOME = WF_CONF["sanxot"]
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
        PARAMS[exp]["tags"] = [x.strip() for x in indat["tags"].split(',')]
        PARAMS[exp]["control_tag"] = indat["control_tag"]
        PARAMS[exp]["first_tag"]   = indat["first_tag"]
        if WF_HOME["rels2sp"]["enabled"]:
            yield expand([
                "{outdir}/{wfname}/{exp}/{tag}/s2p_rels.xls",
                "{outdir}/{wfname}/{exp}/{tag}/scans.tsv"],
                outdir=indat["outdir"], wfname=WF_NAME, exp=exp, tag=PARAMS[exp]["tags"])

def replace_optparams(optparams, tag, controltag):
    # replace the variable values
    optrep = {
        "-TAG-": str(tag),
        "-CONTROLTAG-": str(controltag)
    }
    optrep = dict((re.escape(k), v) for k, v in optrep.items())
    pattern = re.compile("|".join(optrep.keys()))
    a = ""
    for met, pval in optparams.items():
        a += "{"+met +":"+ pattern.sub( lambda m: optrep[re.escape(m.group(0))], pval ) +"}"
    return a

rule all:
    '''
    Config the output files
    '''
    input:
        infiles( WF_IDAT )

if WF_HOME["rels2sp"]["enabled"]:
    rule rels2sp:
        '''
        Create the relationship tables for scan2peptide
        '''
        threads: 1
        message: "Executing create_rels with {threads} threads"
        input:
            idqfile = lambda wc: PARAMS[wc.exp]["wksdir"] +"/"+ wc.exp +"/ID-q.txt"
        params:
            optparams = lambda wc: replace_optparams(WF_HOME["rels2sp"]["optparams"], wc.tag, PARAMS[wc.exp]["control_tag"])
        output:
            relfile = "{outdir}/{wfname}/{exp}/{tag}/s2p_rels.xls",
            scanfile = "{outdir}/{wfname}/{exp}/{tag}/scans.tsv"
        log:
            "{outdir}/{wfname}/sanxot.log"
        shell:
            "{WF_SRC}/venv_win/Scripts/activate && python {WF_SRC}/rels2sp.py -i {input.idqfile} -r {output.relfile} -s {output.scanfile} -p \"{params.optparams}\" "

if WF_HOME["rels2pq"]["enabled"]:
    rule rels2pq:
        '''
        Create the relationship tables for peptide2protein
        '''
        threads: 1
        message: "Executing create_rels with {threads} threads"
        input:
            idqfile = lambda wc: PARAMS[wc.exp]["wksdir"] +"/"+ wc.exp +"/ID-q.txt"
        params:
            optparams = lambda wc: replace_optparams(WF_HOME["rels2sp"]["optparams"], wc.tag, PARAMS[wc.exp]["control_tag"])
        output:
            relfile = "{outdir}/{wfname}/{exp}/{tag}/s2p_rels.xls",
            scanfile = "{outdir}/{wfname}/{exp}/{tag}/scans.tsv"
        log:
            "{outdir}/{wfname}/sanxot.log"
        shell:
            "{WF_SRC}/venv_win/Scripts/activate && python {WF_SRC}/rels2sp.py -i {input.idqfile} -r {output.relfile} -s {output.scanfile} -p \"{params.optparams}\" "

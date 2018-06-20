import os
import pandas
import pprint


# Workflow home
IQPROTEO_HOME      = os.environ['IQPROTEO_HOME']
R_HOME            = os.environ['R_HOME']
WF_PRESANXOT_SRC  = IQPROTEO_HOME+"/src/Pre-SanXoT2"
WF_SANXOT_VENV    = IQPROTEO_HOME+"/venv_win64/venv_win64_py27"
WF_SANXOT_SRC     = IQPROTEO_HOME+"/src/SanXoT"

# Config variables for workflow
INFILE_DAT = config["indata"]
INFILE_CAT = config["catfile"]
WF_HOME = config["workflow"]
WF_PRESANXOT_HOME = WF_HOME["presanxot2"]
WF_SANXOT_HOME    = WF_HOME["sanxot"]
WF_VERBOSE_MODE   = " -v " if WF_HOME["verbose"] else ""

# File names
FNAME_PRESANXOT_IDALL = config["idafname"]
FNAME_PRESANXOT_QALL  = config["qallfname"]
FNAME_PRESANXOT_IDQ   = config["idqfname"]
FNAME_SANXOT_RELS2P   = "s2p_rels.xls"
FNAME_SANXOT_RELP2Q   = "p2q_rels.xls"
FNAME_SANXOT_RELQ2C   = "q2c_rels.xls"
FNAME_SANXOT_SCNS     = "scans.xls"
FNAME_SANXOT_PEPS     = "peptides.xls"
FNAME_SANXOT_PROS     = "proteins.xls"
FNAME_SANXOT_CATS     = "categories.xls"
FNAME_SANXOT_P2ALL    = "pep2all.log"
FNAME_SANXOT_Q2ALL    = "pro2all.log"
FNAME_SANXOT_C2ALL    = "cat2all.log"

# Config variables from the input data
PARAMS = {}

def create_tag_outdir(basedir, subdir, name):
    '''
    Join the path to create the output directory
    '''
    outdir = basedir
    if subdir != "":
        outdir += "/"+subdir
    if name != "":
        outdir += "/"+name
    return outdir

def infiles(ifile):
    '''
    Handles the input data (output files for the workflow)
    '''
    indata = pandas.read_excel(ifile, converters={ "msfdir":str, "idedir":str, "outdir":str, "experiment":str, "name":str, "tag":str, "ratio_numerator":str, "ratio_denominator":str})

    # output files created by pre-sanxot workflow
    # get input values for every data
    for exp in indata["experiment"].unique():
        # create a list with the unique values and extract the first element
        PARAMS[exp] = {}
        PARAMS[exp]["names"] = {}        
        PARAMS[exp]["msfdir"] = indata.loc[indata["experiment"] == exp, "msfdir"].unique()[0]
        PARAMS[exp]["idedir"] = indata.loc[indata["experiment"] == exp, "idedir"].unique()[0]        
        PARAMS[exp]["outdir"] = indata.loc[indata["experiment"] == exp, "outdir"].unique()[0]
        PARAMS[exp]["tags"] = ",".join( [str(x).strip() for x in indata.loc[indata["experiment"] == exp, "tag"]] )
        PARAMS[exp]["ratio_numerator"] = ""
        for x in indata.loc[indata["experiment"] == exp, "ratio_numerator"]:
            if not pandas.isnull(x):
                PARAMS[exp]["ratio_numerator"] += str(x).strip() +","
        PARAMS[exp]["ratio_numerator"] = PARAMS[exp]["ratio_numerator"][:-1]
        # TODO!!
        # At the moment, we have one ratio denominator for all the tags.
        # We extract the first (not null) value
        # But another idea for the future it is to have one numerator/denominator per tag
        for x in indata.loc[indata["experiment"] == exp, "ratio_denominator"].unique():
            if not pandas.isnull(x):
                PARAMS[exp]["ratio_denominator"] = str(x).strip()
        if WF_PRESANXOT_HOME["create_qall"]["enabled"]:
            yield "{outdir}/{exp}/{fname}".format(outdir=PARAMS[exp]["outdir"], exp=exp, fname=FNAME_PRESANXOT_QALL)
        if WF_PRESANXOT_HOME["create_idq"]["enabled"]:
            yield "{outdir}/{exp}/{fname}".format(outdir=PARAMS[exp]["outdir"], exp=exp, fname=FNAME_PRESANXOT_IDQ)
    
    # output files created by sanxot workflow
    # for each row
    for idx, indat in indata.iterrows():
        outdir = indat["outdir"]
        exp    = indat["experiment"]
        name   = indat["name"]
        tag    = indat["tag"]
        ratio_num = indat["ratio_numerator"]
        ratio_den = indat["ratio_denominator"]
        PARAMS[exp]["names"][name] = {}
        PARAMS[exp]["names"][name]["tag"] = tag
        # ratio numerator and denominator have to be defined
        if not pandas.isnull(ratio_num) and not pandas.isnull(ratio_den):
            PARAMS[exp]["names"][name]["ratio_num"] = ratio_num
            PARAMS[exp]["names"][name]["ratio_den"] = ratio_den
            if WF_SANXOT_HOME["rels2sp"]["enabled"]:
                yield expand(["{outdir}/{exp}/{name}/{fname1}", "{outdir}/{exp}/{name}/{fname2}"], outdir=outdir, exp=exp, name=name, fname1=FNAME_SANXOT_RELS2P, fname2=FNAME_SANXOT_SCNS)
            if WF_SANXOT_HOME["rels2pq"]["enabled"]:                        
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_RELP2Q)
            if WF_SANXOT_HOME["rels2pq_unique"]["enabled"]:                        
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_RELP2Q)
            if WF_SANXOT_HOME["scan2peptide"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_PEPS)
            if WF_SANXOT_HOME["peptide2protein"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_PROS)
            if WF_SANXOT_HOME["protein2category"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_CATS)
            if WF_SANXOT_HOME["peptide2all"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_P2ALL)
            if WF_SANXOT_HOME["protein2all"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_Q2ALL)
            if WF_SANXOT_HOME["category2all"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=outdir, exp=exp, name=name, fname=FNAME_SANXOT_C2ALL)


rule all:
    '''
    Config the output files
    '''
    input:
        infiles( INFILE_DAT )

# pprint.pprint( PARAMS )



def replace_optparams(optparams, tag=None, controltags=None):
    '''
    Replace the variable values
    '''
    ctrtags = str(controltags)
    if len(ctrtags.split(",")) > 1:
        ctrtags = "Mean"
    optrep = {
        "-TAG-": str(tag),
        "-CONTROLTAG-": str(ctrtags)
    }
    optrep = dict((re.escape(k), v) for k, v in optrep.items())
    pattern = re.compile("|".join(optrep.keys()))
    a = ""
    for met, pval in optparams.items():
        a += "{"+met +":"+ pattern.sub( lambda m: optrep[re.escape(m.group(0))], pval ) +"}"
    return a



if WF_PRESANXOT_HOME["create_qall"]["enabled"]:   
    rule create_qall:
        '''
        Create the Q-all from the MSF information of PD
        '''
        threads: 1
        message: "Executing 'create_qall' with {threads} threads for {wildcards.exp}"
        params:
            msfdir = lambda wc: PARAMS[wc.exp]["msfdir"],
            tags   = lambda wc: PARAMS[wc.exp]["tags"]
        output:
            qallfile = "{outdir}/{exp}/"+FNAME_PRESANXOT_QALL
        log:
            "{outdir}/{exp}/presanxot2.log"
        shell:
            '"{R_HOME}/bin/Rscript" --vanilla "{WF_PRESANXOT_SRC}/create_q-all.R" \
                --indir "{params.msfdir}" \
                --tags  "{params.tags}" \
                --outfile "{output.qallfile}" 1>> "{log}" 2>&1 '

if WF_PRESANXOT_HOME["create_idq"]["enabled"]:
    rule create_idq:
        '''
        Create the ID-Q output file
        '''
        threads: 1
        message: "Executing 'create_idq' with {threads} threads for {wildcards.exp}"
        input:
            idenfile = lambda wc: PARAMS[wc.exp]["idedir"]+"/"+ FNAME_PRESANXOT_IDALL,
            qallfile = lambda wc: PARAMS[wc.exp]["outdir"]+"/"+wc.exp+"/"+FNAME_PRESANXOT_QALL if WF_PRESANXOT_HOME["create_qall"]["enabled"] else PARAMS[wc.exp]["msfdir"]+"/"+FNAME_PRESANXOT_QALL
        params:
            tags         = lambda wc: PARAMS[wc.exp]["tags"],
            ratio_numer  = lambda wc: PARAMS[wc.exp]["ratio_numerator"],
            ratio_denom  = lambda wc: PARAMS[wc.exp]["ratio_denominator"],
            abs_calc     = WF_PRESANXOT_HOME["create_idq"]["abs_calc"],
            random       = WF_PRESANXOT_HOME["create_idq"]["random"],
            filt_orphans = WF_PRESANXOT_HOME["create_idq"]["filt_orphans"],
            no_mod_mass  = WF_PRESANXOT_HOME["create_idq"]["no_mod_mass"]
        output:
            idqfile = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDQ
        log:
            "{outdir}/{exp}/presanxot2.log"
        shell:
            '"{R_HOME}/bin/Rscript" --vanilla "{WF_PRESANXOT_SRC}/create_id-q.R" \
                --in_ident "{input.idenfile}" \
                --in_quant "{input.qallfile}" \
                --tags  "{params.tags}" \
                --ratio_numer  "{params.ratio_numer}" \
                --ratio_denom  "{params.ratio_denom}" \
                --abs_calc  "{params.abs_calc}" \
                --random  "{params.random}" \
                --filt_orphans  "{params.filt_orphans}" \
                --no_mod_mass "{params.no_mod_mass}" \
                --outfile "{output.idqfile}" 1>> "{log}" 2>&1 '

if WF_SANXOT_HOME["rels2sp"]["enabled"]:
    rule rels2sp:
        '''
        Create the relationship tables for scan2peptide
        '''
        threads: 1
        message: "Executing 'rels2sp' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            idqfile = lambda wc: PARAMS[wc.exp]["outdir"] +"/"+ wc.exp +"/"+FNAME_PRESANXOT_IDQ if WF_PRESANXOT_HOME["create_idq"]["enabled"] else PARAMS[wc.exp]["idedir"]+"/"+FNAME_PRESANXOT_IDQ
        params:
            optparams = lambda wc: replace_optparams(WF_SANXOT_HOME["rels2sp"]["optparams"], PARAMS[wc.exp]["names"][wc.name]["tag"], PARAMS[wc.exp]["names"][wc.name]["ratio_den"])
        output:
            relfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELS2P,
            scanfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_SCNS
        log:
            "{outdir}/{exp}/{name}/rels2sp.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/rels2sp.py" --idqfile "{input.idqfile}" --relfile "{output.relfile}" --scanfile "{output.scanfile}" --params "{params.optparams}" --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["rels2pq"]["enabled"]:
    rule rels2pq:
        '''
        Create the relationship tables for peptide2protein
        '''
        threads: 1
        message: "Executing 'rels2pq' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            idqfile = lambda wc: PARAMS[wc.exp]["outdir"] +"/"+ wc.exp +"/"+FNAME_PRESANXOT_IDQ if WF_PRESANXOT_HOME["create_idq"]["enabled"] else PARAMS[wc.exp]["idedir"]+"/"+FNAME_PRESANXOT_IDQ
        params:
            optparams = lambda wc: replace_optparams(WF_SANXOT_HOME["rels2pq"]["optparams"])
        output:
            relfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELP2Q
        log:
            "{outdir}/{exp}/{name}/rels2pq.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/rels2pq.py" --idqfile "{input.idqfile}" --relfile "{output.relfile}" --params "{params.optparams}" --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["rels2pq_unique"]["enabled"]:
    rule rels2pq_unique:
        '''
        Create the relationship tables for peptide2protein
        '''
        threads: 1
        message: "Executing 'rels2pq_unique' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            idqfile = lambda wc: PARAMS[wc.exp]["outdir"] +"/"+ wc.exp +"/"+FNAME_PRESANXOT_IDQ if WF_PRESANXOT_HOME["create_idq"]["enabled"] else PARAMS[wc.exp]["idedir"]+"/"+FNAME_PRESANXOT_IDQ
        params:
            species   = WF_SANXOT_HOME["rels2pq_unique"]["species"],
            pretxt    = expand(["\"{ptxt}\""], ptxt=WF_SANXOT_HOME["rels2pq_unique"]["pretxt"]),
            optparams = lambda wc: replace_optparams(WF_SANXOT_HOME["rels2pq_unique"]["optparams"])
        output:
            relfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELP2Q
        log:
            "{outdir}/{exp}/{name}/rels2pq_unique.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/rels2pq_unique.py" --idqfile "{input.idqfile}" --species "{params.species}" --pretxt {params.pretxt} --relfile "{output.relfile}" --params "{params.optparams}" --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["scan2peptide"]["enabled"]:
    rule scan2peptide:
        '''
        Execute scan to peptide
        '''
        threads: 1
        message: "Executing 'scan2peptide' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            relfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELS2P,
            scanfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_SCNS
        params:
            fdr       = WF_SANXOT_HOME["scan2peptide"]["fdr"],
            optparams = replace_optparams(WF_SANXOT_HOME["scan2peptide"]["optparams"])
        output:
            pepfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PEPS
        log:
            "{outdir}/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/scan2peptide.py" --scanfile "{input.scanfile}" --relfile "{input.relfile}" --fdr "{params.fdr}" --pepfile "{output.pepfile}" --params "{params.optparams}" --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["peptide2protein"]["enabled"]:
    rule peptide2protein:
        '''
        Execute scan to peptide
        '''
        threads: 1
        message: "Executing 'peptide2protein' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            relfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELP2Q,
            pepfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PEPS
        params:
            fdr       = WF_SANXOT_HOME["peptide2protein"]["fdr"],
            optparams = replace_optparams(WF_SANXOT_HOME["peptide2protein"]["optparams"])
        output:
            profile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PROS
        log:
            "{outdir}/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/peptide2protein.py" --pepfile "{input.pepfile}" --relfile "{input.relfile}" --fdr "{params.fdr}" --profile "{output.profile}" --params "{params.optparams}" --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["protein2category"]["enabled"]:
    rule protein2category:
        '''
        Execute scan to peptide
        '''
        threads: 1
        message: "Executing 'protein2category' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            relfile = INFILE_CAT,
            profile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PROS
        params:
            fdr       = WF_SANXOT_HOME["protein2category"]["fdr"],
            optparams = replace_optparams(WF_SANXOT_HOME["protein2category"]["optparams"])
        output:
            catfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_CATS
        log:
            "{outdir}/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/protein2category.py" --profile "{input.profile}" --relfile "{input.relfile}" --fdr "{params.fdr}" --catfile "{output.catfile}" --params "{params.optparams}" --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["peptide2all"]["enabled"]:
    rule peptide2all:
        '''
        Execute peptide to all
        '''
        threads: 1
        message: "Executing 'peptide2all' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            pepfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PEPS
        params:
            optparams = replace_optparams(WF_SANXOT_HOME["peptide2all"]["optparams"])
        output:
            p2afile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_P2ALL
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/peptide2all.py" --pepfile "{input.pepfile}" --params "{params.optparams}" --logfile "{output.p2afile}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["protein2all"]["enabled"]:
    rule protein2all:
        '''
        Execute protein to all
        '''
        threads: 1
        message: "Executing 'protein2all' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            profile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PROS
        params:
            optparams = replace_optparams(WF_SANXOT_HOME["protein2all"]["optparams"])
        output:
            q2afile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_Q2ALL
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/protein2all.py" --profile "{input.profile}" --params "{params.optparams}" --logfile "{output.q2afile}" {WF_VERBOSE_MODE}'

if WF_SANXOT_HOME["category2all"]["enabled"]:
    rule category2all:
        '''
        Execute category to all
        '''
        threads: 1
        message: "Executing 'category2all' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            catfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_CATS
        params:
            optparams = replace_optparams(WF_SANXOT_HOME["category2all"]["optparams"])
        output:
            c2afile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_C2ALL
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && python "{WF_SANXOT_SRC}/category2all.py" --catfile "{input.catfile}" --params "{params.optparams}" --logfile "{output.c2afile}" {WF_VERBOSE_MODE}'

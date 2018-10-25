import os
import pandas
import pprint

# Workflow home
IQPROTEO_HOME     = os.environ['IQPROTEO_HOME']
R_HOME            = os.environ['R_HOME']
WF_PRATIO_SRC     = IQPROTEO_HOME+"/src/pRatio"
WF_PRESANXOT_SRC  = IQPROTEO_HOME+"/src/Pre-SanXoT2"
WF_SANXOT_VENV    = IQPROTEO_HOME+"/venv_win64/venv_win64_py27"
WF_SANXOT_SRC     = IQPROTEO_HOME+"/src/SanXoT"

# Config variables for workflow
INFILE_DAT        = config["indata"]
INDIR             = config["indir"]
OUTDIR            = config["outdir"]
INFILE_CAT        = config["catfile"]
INFILE_MOD        = config["modfile"]
WF_HOME           = config["workflow"]
WF_PRATIO_HOME    = WF_HOME["pratio"]
WF_PRESANXOT_HOME = WF_HOME["presanxot2"]
WF_SANXOT_HOME    = WF_HOME["sanxot"]
WF_VERBOSE_MODE   = " -vv " if WF_HOME["verbose"] else ""

# Output file names
FNAME_PRESANXOT_IDALL = config["idafname"]
FNAME_PRESANXOT_QALL  = config["qallfname"]
FNAME_PRESANXOT_IDQ   = config["idqfname"]
FNAME_SANXOT_RELS2P   = "s2p_rels.tsv"
FNAME_SANXOT_RELP2Q   = "p2q_rels.tsv"
FNAME_SANXOT_RELQ2C   = "q2c_rels.tsv"
FNAME_SANXOT_USCNS    = "u_scans.tsv"
FNAME_SANXOT_SCNS     = "scans.tsv"
FNAME_SANXOT_PEPS     = "peptides.tsv"
FNAME_SANXOT_PROS     = "proteins.tsv"
FNAME_SANXOT_CATS     = "categories.tsv"
FNAME_SANXOT_P2ALL    = "pep2all.tsv"
FNAME_SANXOT_Q2ALL    = "pro2all.tsv"
FNAME_SANXOT_C2ALL    = "cat2all.tsv"

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
    indata = pandas.read_csv(ifile, converters={"experiment":str, "name":str, "tag":str, "ratio_numerator":str, "ratio_denominator":str})

    # output files created by pratio and pre-sanxot workflow
    # get input values for every data
    for exp in indata["experiment"].unique():
        # create a list with the unique values and extract the first element
        PARAMS[exp] = {}
        PARAMS[exp]["names"] = {}        
        # PARAMS[exp]["indir"] = indata.loc[indata["experiment"] == exp, "indir"].unique()[0]        
        PARAMS[exp]["indir"] = INDIR
        PARAMS[exp]["outdir"] = OUTDIR
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
        if WF_PRATIO_HOME["pratio"]["enabled"]:
            yield "{outdir}/{exp}/{fname}".format(outdir=PARAMS[exp]["outdir"], exp=exp, fname=FNAME_PRESANXOT_IDALL)
        if WF_PRESANXOT_HOME["create_qall"]["enabled"]:
            yield "{outdir}/{exp}/{fname}".format(outdir=PARAMS[exp]["outdir"], exp=exp, fname=FNAME_PRESANXOT_QALL)
        if WF_PRESANXOT_HOME["create_idq"]["enabled"]:
            yield "{outdir}/{exp}/{fname}".format(outdir=PARAMS[exp]["outdir"], exp=exp, fname=FNAME_PRESANXOT_IDQ)
    
    # output files created by sanxot workflow
    # for each row
    for idx, indat in indata.iterrows():
        exp    = indat["experiment"]
        name   = indat["name"]
        tag    = indat["tag"]
        ratio_num = indat["ratio_numerator"]
        ratio_den = indat["ratio_denominator"]
        PARAMS[exp]["names"][name] = {}
        PARAMS[exp]["names"][name]["tag"] = tag
        # ratio numerator and denominator have to be defined
        if not pandas.isnull(ratio_num) and not pandas.isnull(ratio_den) and not ratio_num == "" and not ratio_den == "":
            PARAMS[exp]["names"][name]["ratio_num"] = ratio_num
            PARAMS[exp]["names"][name]["ratio_den"] = ratio_den
            if WF_PRESANXOT_HOME["rels2sp"]["enabled"]:
                yield expand(["{outdir}/{exp}/{name}/{fname1}", "{outdir}/{exp}/{name}/{fname2}"], outdir=OUTDIR, exp=exp, name=name, fname1=FNAME_SANXOT_RELS2P, fname2=FNAME_SANXOT_USCNS)
            if WF_PRESANXOT_HOME["rels2pq"]["enabled"]:                        
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_RELP2Q)
            if WF_PRESANXOT_HOME["rels2pq_unique"]["enabled"]:                        
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_RELP2Q)
            if WF_SANXOT_HOME["scan2peptide"]["enabled"]:
                yield expand(["{outdir}/{exp}/{name}/{fname1}", "{outdir}/{exp}/{name}/{fname2}"], outdir=OUTDIR, exp=exp, name=name, fname1=FNAME_SANXOT_SCNS, fname2=FNAME_SANXOT_PEPS)
            if WF_SANXOT_HOME["peptide2protein"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_PROS)
            if WF_SANXOT_HOME["protein2category"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_CATS)
            if WF_SANXOT_HOME["peptide2all"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_P2ALL)
            if WF_SANXOT_HOME["protein2all"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_Q2ALL)
            if WF_SANXOT_HOME["category2all"]["enabled"]:
                yield "{outdir}/{exp}/{name}/{fname}".format(outdir=OUTDIR, exp=exp, name=name, fname=FNAME_SANXOT_C2ALL)


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


# ---------------- #
# pRatioR: methods #
# ---------------- #
if WF_PRATIO_HOME["pratio"]["enabled"]:   
    rule pratio:
        '''
        Create the pRatio for all MSF files from PD
        '''
        threads: 1
        message: "Executing 'pratio' with {threads} threads for {wildcards.exp}"
        params:
            # indir = lambda wc: PARAMS[wc.exp]["indir"],
            indir      = INDIR,
            regex      = lambda wc: wc.exp,
            mod_file   = INFILE_MOD,
            threshold  = WF_PRATIO_HOME["pratio"]["threshold"],
            delta_mass = WF_PRATIO_HOME["pratio"]["delta_mass"],
            tag_mass   = WF_PRATIO_HOME["pratio"]["tag_mass"],
            lab_decoy  = WF_PRATIO_HOME["pratio"]["lab_decoy"]
        output:
            idallfile  = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDALL
        log:
            "{outdir}/tmp/{exp}/pratio.log"
        shell:
            '"{R_HOME}/bin/Rscript" --vanilla "{WF_PRATIO_SRC}/pRatio.R" \
                --msf_dir "{params.indir}" \
                --regex "{params.regex}" \
                --mod_file "{params.mod_file}" \
                --threshold "{params.threshold}" \
                --delta_mass "{params.delta_mass}" \
                --tag_mass "{params.tag_mass}" \
                --lab_decoy "{params.lab_decoy}" \
                --outfile "{output.idallfile}" 1>> "{log}" 2>&1 '

# -------------------- #
# Pre-SanXoT2: methods #
# -------------------- #
if WF_PRESANXOT_HOME["create_qall"]["enabled"]:   
    rule create_qall:
        '''
        Create the Q-all from the MSF information of PD
        '''
        threads: 1
        message: "Executing 'create_qall' with {threads} threads for {wildcards.exp}"
        params:
            indir    = lambda wc: PARAMS[wc.exp]["indir"],
            regex    = lambda wc: wc.exp,
            tags     = lambda wc: PARAMS[wc.exp]["tags"]
        output:
            qallfile = "{outdir}/{exp}/"+FNAME_PRESANXOT_QALL
        log:
            "{outdir}/tmp/{exp}/presanxot2_qall.log"
        shell:
            '"{R_HOME}/bin/Rscript" --vanilla "{WF_PRESANXOT_SRC}/create_q-all.R" \
                --msf_dir "{params.indir}" \
                --regex "{params.regex}" \
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
            idenfile     = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDALL,
            qallfile     = "{outdir}/{exp}/"+FNAME_PRESANXOT_QALL
        params:
            tags         = lambda wc: PARAMS[wc.exp]["tags"],
            ratio_numer  = lambda wc: PARAMS[wc.exp]["ratio_numerator"],
            ratio_denom  = lambda wc: PARAMS[wc.exp]["ratio_denominator"],
            abs_calc     = WF_PRESANXOT_HOME["create_idq"]["abs_calc"],
            random       = WF_PRESANXOT_HOME["create_idq"]["random"],
            filt_orphans = WF_PRESANXOT_HOME["create_idq"]["filt_orphans"],
            no_mod_mass  = WF_PRESANXOT_HOME["create_idq"]["no_mod_mass"]
        output:
            idqfile      = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDQ
        log:
            "{outdir}/tmp/{exp}/presanxot2_idq.log"
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

if WF_PRESANXOT_HOME["rels2sp"]["enabled"]:
    rule rels2sp:
        '''
        Create the relationship tables for scan2peptide
        '''
        threads: 1
        message: "Executing 'rels2sp' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            idqfile   = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDQ
        params:
            optparams = lambda wc: replace_optparams(WF_PRESANXOT_HOME["rels2sp"]["optparams"], PARAMS[wc.exp]["names"][wc.name]["tag"], PARAMS[wc.exp]["names"][wc.name]["ratio_den"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            relfile   = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELS2P,
            scanfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_USCNS
        log:
            "{outdir}/tmp/{exp}/{name}/rels2sp.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/rels2sp.py" \
              --idqfile "{input.idqfile}" \
              --relfile "{output.relfile}" \
              --scanfile "{output.scanfile}" \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_PRESANXOT_HOME["rels2pq"]["enabled"]:
    rule rels2pq:
        '''
        Create the relationship tables for peptide2protein
        '''
        threads: 1
        message: "Executing 'rels2pq' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            idqfile   = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDQ
        params:
            optparams = lambda wc: replace_optparams(WF_PRESANXOT_HOME["rels2pq"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            relfile   = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELP2Q
        log:
            "{outdir}/tmp/{exp}/{name}/rels2pq.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/rels2pq.py" \
              --idqfile "{input.idqfile}" \
              --relfile "{output.relfile}" \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

if WF_PRESANXOT_HOME["rels2pq_unique"]["enabled"]:
    rule rels2pq_unique:
        '''
        Create the relationship tables for peptide2protein
        '''
        threads: 1
        message: "Executing 'rels2pq_unique' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:
            idqfile   = "{outdir}/{exp}/"+FNAME_PRESANXOT_IDQ
        params:
            species   = WF_PRESANXOT_HOME["rels2pq_unique"]["species"],
            pretxt    = expand(["\"{ptxt}\""], ptxt=WF_PRESANXOT_HOME["rels2pq_unique"]["pretxt"]),
            optparams = lambda wc: replace_optparams(WF_PRESANXOT_HOME["rels2pq_unique"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            relfile   = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELP2Q
        log:
            "{outdir}/tmp/{exp}/{name}/rels2pq_unique.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/rels2pq_unique.py" \
              --idqfile "{input.idqfile}" \
              --species "{params.species}" \
              --pretxt {params.pretxt} \
              --relfile "{output.relfile}" \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

# --------------- #
# SanXoT: methods #
# --------------- #

if WF_SANXOT_HOME["scan2peptide"]["enabled"]:
    rule scan2peptide:
        '''
        Execute scan to peptide
        '''
        threads: 1
        message: "Executing 'scan2peptide' with {threads} threads for {wildcards.exp}/{wildcards.name}"
        input:            
            uscanfile = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_USCNS,
            relfile   = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_RELS2P            
        params:
            fdr       = WF_SANXOT_HOME["scan2peptide"]["fdr"],
            variance  = ' --variance "'+str(WF_SANXOT_HOME["scan2peptide"]["variance"])+'" ' if "variance" in WF_SANXOT_HOME["scan2peptide"] else '',
            optparams = replace_optparams(WF_SANXOT_HOME["scan2peptide"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            scanfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_SCNS,
            pepfile   = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PEPS
        log:
            "{outdir}/tmp/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/scan2peptide.py" \
              --uscanfile "{input.uscanfile}" \
              --relfile "{input.relfile}" \
              --scanfile "{output.scanfile}" \
              --pepfile "{output.pepfile}" \
              --fdr "{params.fdr}" \
              {params.variance} \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

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
            variance  = ' --variance "'+str(WF_SANXOT_HOME["peptide2protein"]["variance"])+'" ' if "variance" in WF_SANXOT_HOME["peptide2protein"] else '',
            optparams = replace_optparams(WF_SANXOT_HOME["peptide2protein"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            profile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_PROS
        log:
            "{outdir}/tmp/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/peptide2protein.py" \
              --pepfile "{input.pepfile}" \
              --relfile "{input.relfile}" \
              --profile "{output.profile}" \
              --fdr "{params.fdr}" \
              {params.variance} \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

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
            variance  = ' --variance "'+str(WF_SANXOT_HOME["protein2category"]["variance"])+'" ' if "variance" in WF_SANXOT_HOME["protein2category"] else '',
            optparams = replace_optparams(WF_SANXOT_HOME["protein2category"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            catfile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_CATS
        log:
            "{outdir}/tmp/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/protein2category.py" \
              --profile "{input.profile}" \
              --relfile "{input.relfile}" \
              --catfile "{output.catfile}" \
              --fdr "{params.fdr}" \
              {params.variance} \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

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
            optparams = replace_optparams(WF_SANXOT_HOME["peptide2all"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            p2afile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_P2ALL
        log:
            "{outdir}/tmp/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/peptide2all.py" \
              --pepfile "{input.pepfile}" \
              --p2afile "{output.p2afile}" \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

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
            optparams = replace_optparams(WF_SANXOT_HOME["protein2all"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            q2afile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_Q2ALL
        log:
            "{outdir}/tmp/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/protein2all.py" \
              --profile "{input.profile}" \
              --q2afile "{output.q2afile}" \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

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
            optparams = replace_optparams(WF_SANXOT_HOME["category2all"]["optparams"]),
            tmpdir    = "{outdir}/tmp/{exp}/{name}"
        output:
            c2afile  = "{outdir}/{exp}/{name}/"+FNAME_SANXOT_C2ALL
        log:
            "{outdir}/tmp/{exp}/{name}/sanxot.log"
        shell:
            '"{WF_SANXOT_VENV}/Scripts/activate" && \
            python "{WF_SANXOT_SRC}/category2all.py" \
              --catfile "{input.catfile}" \
              --c2afile "{output.c2afile}" \
              --params "{params.optparams}" \
              --tmpdir "{params.tmpdir}" \
              --logfile "{log}" {WF_VERBOSE_MODE}'

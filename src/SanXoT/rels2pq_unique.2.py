#!/usr/bin/python

# import global modules
import os
import sys
import argparse
import logging
import numpy
import re

import pprint

# Module metadata variables
__author__ = "Jose Rodriguez"
__credits__ = ["Jose Rodriguez", "Jesus Vazquez"]
__license__ = "Creative Commons Attribution-NonCommercial-NoDerivs 4.0 Unported License https://creativecommons.org/licenses/by-nc-nd/4.0/"
__version__ = "1.0.1"
__maintainer__ = "Jose Rodriguez"
__email__ = "jmrodriguezc@cnic.es"
__status__ = "Development"

class corrector:
    '''
    Make the calculations in the workflow
    '''
    LPP = 1

    def __init__(self, infile, species=None, pretxt=None, indb=None):
        # create species filter
        self.species = species
        # create preferenced text
        self.pretxt = pretxt
        # create an index from the fasta sequence, if apply
        self.indb = None        
        if indb is not None:
            # get the index of proteins: for UniProt case!! (key_function)
            self.indb = SeqIO.index(indb, "fasta", key_function=lambda rec : rec.split("|")[1])
        # create the report with the peptides and proteins
        # usecols=("Sequence", "FASTAProteinDescription", "Redundances"))
        self.data = numpy.genfromtxt(infile, delimiter="\t", dtype="string", comments=None, skip_header=1, usecols=[6,7,10])
        self.proteins = self.get_reports( self.data )
        logging.debug( pprint.pformat(self.proteins) )
        # header for the output
        self.rst_header = ['[FASTAProteinDescription]', '[Sequence]', '[Tags]']

    # def _extract_proteins(self, descs, species=None):
    #     '''
    #     Extract the protein IDs from a list of FASTA descriptions (for the moment, only applied for UniProtKB)
    #     Extract the species names from a list of FASTA descriptions (for the moment, only applied for UniProtKB)        
    #     '''        
    #     prot_ids = {}
    #     for desc in descs:
    #         # discard NaN values
    #         if desc:
    #             for d in desc.split(">")[1:]:
    #                 # SwissProt/TrEMBL descriptions
    #                 if re.search(r'^[sp|tr]', d):
    #                     # extract proteins
    #                     p_id = d.split("|")[1]
    #                     # extract species
    #                     sp = re.search(r'OS=(\w* \w*)', d, re.I | re.M).group(1)
    #                     if species is None:
    #                         prot_ids[p_id] = { 'id': p_id, 'desc': ">"+d, 'species': sp }
    #                     elif species == sp:
    #                         prot_ids[p_id] = { 'id': p_id, 'desc': ">"+d, 'species': sp }
    #     return prot_ids
    def _extract_proteins(self, descs):
        '''
        Extract the protein IDs, description, and species from a list of FASTA descriptions (for the moment, only applied for UniProtKB)
        '''        
        prot_ids = {}
        for desc in descs:
            # discard NaN values
            if desc:
                for d in desc.split(">")[1:]:
                    # SwissProt/TrEMBL descriptions
                    if re.search(r'^[sp|tr]', d):
                        # extract proteins
                        p_id = d.split("|")[1]
                        # extract species
                        sp = re.search(r'OS=(\w* \w*)', d, re.I | re.M).group(1)
                        prot_ids[p_id] = { 'id': p_id, 'desc': ">"+d, 'species': sp }

        return prot_ids
        
    def get_reports(self, data):
        '''
        Create the report with the protein values
        Extract the unique tuples from the input (peptides)
        '''
        proteins = {}
        # extract the peptide and proteins info for each line
        for data in data:
            # extract init variables
            pep_lpp = self.LPP # IMPORTANT!!!! HARD-CORE the LPP for the PEPTIDE!!!
            pep_seq = data[0]
            pep_dsc = data[1]
            pep_dsc2 = data[2]
            # replace strange characters
            pep_seq = pep_seq.replace(" ", "")
            pep_seq = pep_seq.replace('"', "")
            pep_dsc = pep_dsc.replace('"', "")
            pep_dsc = re.sub('\s*--\s*$', '', pep_dsc)
            # assign variables
            pep_p_seq = pep_seq
            pep_p_dsc = [pep_dsc]
            pep_p_dsc.append(pep_dsc2)
            # get the peptide without PTMs
            pep_p_seq = re.sub('\[[^\]]*\]', '', pep_p_seq) # open search
            pep_p_seq = re.sub('[^a-zA-Z]', '', pep_p_seq) # close search
            # extract the protein ids from a peptide
            pep_prots = self._extract_proteins(pep_p_dsc)
            # save the proteins from peptide.
            # the peptide should be unique
            for qid, pep_prot in pep_prots.items():
                pdsc = pep_prot['desc']
                pspecies = pep_prot['species']
                if qid not in proteins:
                    # init LPQ with the first LPP
                    # with the first peptide
                    proteins[qid] = { 'LPQ': pep_lpp, 'desc': pdsc, 'species': pspecies, 'praw': [pep_p_seq], 'pep': [pep_seq], 'npep': 1, 'nptms': 1, 'scans': 1 }
                else:
                    # check if the peptide is unique
                    # LPQ: Sum of LPP's peptides
                    if pep_p_seq not in proteins[qid]['praw']:
                        proteins[qid]['praw'].append(pep_p_seq)
                        proteins[qid]['npep'] += 1
                    # add the peptide (with modifications)
                    if pep_seq not in proteins[qid]['pep']:
                        proteins[qid]['pep'].append(pep_seq)
                        proteins[qid]['nptms'] += 1
                    # increase the num. scans
                    proteins[qid]['LPQ'] += pep_lpp
                    proteins[qid]['scans'] += 1
            
        return proteins

    def _unique_protein_decision(self, prots):
        '''
        Take an unique protein based on
        '''
        decision = False
        hprot = None
        # 1. the preferenced text, if apply
        if self.pretxt is not None:
            # know how many proteins match to the list of regexp
            for pretxt in self.pretxt:
                pmat = list( filter( lambda x: re.match(r'.*'+pretxt+'.*', x['desc'], re.I | re.M), prots) )
                # keep the matches                
                if pmat is not None and len(pmat) > 0 :
                    prots = pmat
                    # if there is only one protein, we found
                    if len(pmat) == 1:
                        hprot = pmat[0]
                        decision = True
        
        # 2. Take the sorted sequence, if apply
        if (not decision) and (self.indb is not None):
            # extract the proteins that are in the fasta index
            pmat = list( filter( lambda x: x['id'] in self.indb, prots) )
            # extract the sequence length
            pmat = list( map( lambda x: {'id': x['id'], 'desc': x['desc'], 'len': len(self.indb[x['id']].seq)}, pmat) )
            # sort by length
            pmat.sort(key=lambda x: x['len'])
            # extract the sorted sequence, if it is unique
            if pmat is not None:
                if len(pmat) == 1:
                    hprot = pmat[0]
                    decision = True
                elif len(pmat) > 1 and pmat[0]['len'] < pmat[1]['len']:
                    hprot = pmat[0]
                    decision = True                
        
        # 3. Alphabetic order
        if not decision:
            # sort the proteins
            pmat = sorted(prots, key=lambda x: x['desc'], reverse=True)
            if pmat is not None:
                hprot = pmat[0]
                decision = True
        
        return hprot

    def _unique_protein(self, pep_prots, based_on):
        # create a list with the given proteins
        scores = []
        for qid,pep_prot in pep_prots.items():
            if self.proteins[qid]:
                scores.append(self.proteins[qid])
        if scores:
            # get the maximum value
            m = max( [x[based_on] for x in scores] )
            # extract the proteins with the highest value
            s = list(filter(lambda k: k[based_on] == m, scores))
            # if there are more than one proptein, we have to make a decision
            if len(s) == 1:
                rst = s[0]
            elif len(s) > 1:
                rst = self._unique_protein_decision(s)
        else:
            # if not scores we get the given decription
            rst = pep_prots[0]

        # return the description of protein
        l = [ str(x[based_on]) for x in scores ]
        return [rst['desc'], "|".join(l)]

    def get_unique_protein(self):
        '''
        Calculate the unique protein from the list of peptides
        '''
        results = []
        # get the unique list of peptides!!
        for data in numpy.unique(self.data, axis=0):
            pep_p_seq = data[0]
            pep_p_dsc = [data[1]]
            pep_p_dsc.append(data[2])
            # extract the protein ids from a peptide
            pep_prots = self._extract_proteins(pep_p_dsc)
            if pep_prots:
                # get the unique protein based on the num. scans (npep, nptms, scans)
                [hprot,t] = self._unique_protein(pep_prots, 'scans')
                results.append([hprot, pep_p_seq, t])

        return results

    def write_to_file(self, results, outfile):
        '''
        Print to CSV
        '''
        if results:
            rst = "\t".join(self.rst_header) + "\n"
            for r in results:
                rst += "\t".join([str(t) for t in r]) + "\n"
            f = open(outfile, "w")
            f.write(rst)
            f.close()
        else:
            logging.error("Empty output")


def main(args):
    '''
    Main function
    '''
    logging.info('create corrector object')
    co = corrector(args.idqfile, args.species, args.pretxt, args.indb)

    logging.info('calculate the unique protein')
    p = co.get_unique_protein()
    
    logging.info('print output file')
    co.write_to_file(p, args.relfile)


if __name__ == "__main__":
    # parse arguments
    parser = argparse.ArgumentParser(
        description='Create the relationship table for peptide2protein method (get unique protein)',
        epilog='''Examples:
        python  src/SanXoT/rels2pq_unique.2.py
          -i ID-q.txt
          -s "Homo sapiens"
          -p "sp"
          -d Human_jul14.curated.fasta
          -r p2q_rels_unique.tsv
        ''',
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-i',  '--idqfile',  required=True, help='ID-q input file')
    parser.add_argument('-r',  '--relfile',  required=True, help='Output file with the relationship table')
    parser.add_argument('-s',  '--species', help='First filter based on the species name')
    parser.add_argument('-p',  '--pretxt',  nargs='+', type=str, help='in the case of a tie, we apply teh preferenced text checked in the comment line of a protein. Eg. Organism, etc.')
    parser.add_argument('-d',  '--indb',    help='in the case of a tie, we apply the sorted protein sequence using the given FASTA file')
    parser.add_argument('-l',  '--logfile',  help='Output file with the log tracks')
    parser.add_argument('-vv', dest='verbose', action='store_true', help="Increase output verbosity")
    args = parser.parse_args()

    # set-up logging
    scriptname = os.path.splitext( os.path.basename(__file__) )[0]

    # add logging handler, formatting, etc.
    # the logging is info level by default
    # add filehandler
    logger = logging.getLogger()
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    if args.logfile:
        # logfile = os.path.dirname(os.path.realpath(args.relfile)) + "/"+ scriptname +".log"
        ch = logging.FileHandler(args.logfile)
    else:
        ch = logging.StreamHandler()
    ch.setFormatter( logging.Formatter('%(asctime)s - %(levelname)s - '+scriptname+' - %(message)s', '%m/%d/%Y %I:%M:%S %p') )
    logger.addHandler(ch)

    # start main function
    logging.info('start script: '+"{0}".format(" ".join([x for x in sys.argv])))
    main(args)
    logging.info('end script')

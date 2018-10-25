/*
 * Handle parameters
 */
let remote = require('electron').remote;
let dialog = remote.dialog;
let fs = require('fs');
let dtablefilename = '/iq-proteo_data.csv';
let cfgfilename = '/iq-proteo_conf.json'

/*
* Export Datatable to CSV
*/
function parseRow(sizeData, index, infoArray) {
    let cont = "";
    if (index < sizeData - 1) {
        dataString = "";
            infoArray.forEach(function(col,i) {            
            dataString += _.contains(col, ",") ? "\"" + col + "\"" : col;
            dataString += i < _.size(infoArray) - 1 ? "," : "";
        })
        cont = index < sizeData - 2 ? dataString + "\n" : dataString;
    }
    return cont;
}
function exportDatatableCSV(datatable) {
    // add header
    let csvContent = datatable.getColHeader().join(",") + "\n";
    let data = datatable.getData();
    let sizeData = data.length;
    data.forEach(function(row,idx) {
        csvContent += parseRow(sizeData, idx, row);
    });
    return csvContent;
}

// Create Datatable file
function createDatatableFile(outdir) {
    // export Datatable to CSV
    try {
        let datatable = $("#hot").data('handsontable');
        var cont = exportDatatableCSV(datatable);
    } catch (err) {
        console.log("Error exporting datatable: " + err);
        return false;
    }

    // write file sync
    let file = outdir + dtablefilename;
    try {
        fs.writeFileSync(file, cont, 'utf-8');
    } catch (err) {    
        console.log("Error writing datatable file: " + err);
        return false;
    }

    return file;
}

  
/*
* Create config file 
*/
function addConfParams(file, indir, outdir, dtable, modfile, catfile) {
    // get object from template
    let data = JSON.parse(file);

    // add tabledata file
    data['indata'] = dtable;

    // add tabledata file
    data['indir'] = indir;

    // add tabledata file
    data['outdir'] = outdir;

    // add modification
    data['modfile'] = modfile;

    // add category
    data['catfile'] = catfile;

    // wf parameters
    let wf = data['workflow'];
    let wf_pratio = wf['pratio'];
    // let wf_presanxot2 = wf['presanxot2'];
    let wf_sanxot = wf['sanxot'];

    /* --- pRatio --- */
    wf_pratio['pratio']['threshold'] = parseInt(document.querySelector('#deltaMassThreshold').value);
    wf_pratio['pratio']['delta_mass'] = parseInt(document.querySelector('#deltaMassAreas').value);
    wf_pratio['pratio']['tag_mass'] = parseFloat(document.querySelector('#tagMass').value);
    wf_pratio['pratio']['lab_decoy'] = document.querySelector('#tagDecoy').value;


    /* --- Pre-SanXoT2 --- */
    // add to presanxot2 the option of included tags
    // let includeTags = document.querySelector('#includeTags').checked;
    // if ( includeTags ) {
    //     // relationship table s2p
    //     wf_presanxot2['rels2sp']['optparams']['aljamia1'] += ' -l [Tags] ';
    //     wf_presanxot2['rels2sp']['optparams']['aljamia2'] += ' -k [Tags] ';
    //     // relationship table p2q
    //     wf_presanxot2['rels2pq']['optparams']['aljamia1'] += ' -k [Tags] ';
    //     // relationship table p2q_unique
    //     wf_presanxot2['rels2pq_unique']['optparams']['aljamia1'] += ' --c5 [Tags] ';        
    // }

    /* --- SanXoT --- */
    // add FDR
    wf_sanxot['scan2peptide']['fdr'] = parseFloat(document.querySelector('.scan2peptide #fdr').value);
    wf_sanxot['peptide2protein']['fdr'] = parseFloat(document.querySelector('.peptide2protein #fdr').value);
    wf_sanxot['protein2category']['fdr'] = parseFloat(document.querySelector('.protein2category #fdr').value);
    // force the variance if apply
    if ( !document.querySelector('.scan2peptide #variance').disabled ) {
        wf_sanxot['scan2peptide']['variance'] = parseFloat(document.querySelector('.scan2peptide #variance').value);
    }
    if ( !document.querySelector('.peptide2protein #variance').disabled ) {
        wf_sanxot['peptide2protein']['variance'] = parseFloat(document.querySelector('.peptide2protein #variance').value);
    }
    if ( !document.querySelector('.protein2category #variance').disabled ) {
        wf_sanxot['protein2category']['variance'] = parseFloat(document.querySelector('.protein2category #variance').value);
    }    
    // Discard outliers
    let discardOutliers = document.querySelector('#discardOutliers').checked;
    if ( discardOutliers ) {
        wf_sanxot['scan2peptide']['optparams']['sanxot2'] += ' --tags !out ';
        wf_sanxot['peptide2protein']['optparams']['sanxot2'] += ' --tags !out ';
        wf_sanxot['protein2category']['optparams']['sanxot2'] += ' --tags !out ';
    }


    return data;
}

function createConfFile(conf, indir, outdir, dtable, modfile, catfile) {

    // read template file
    try {
        //file exists, get the contents
        let d = fs.readFileSync(conf);

        // create config data with the parameters
        let data = addConfParams(d, indir, outdir, dtable, modfile, catfile);

        // convert JSON to string
        var cont = JSON.stringify(data, undefined, 2);
    } catch (err) {
        console.log("Error creating config file: " + err);
        return false;
    }

    // write file sync
    let file = outdir + cfgfilename;
    try {
        fs.writeFileSync(file, cont, 'utf-8');
    } catch (err) {    
        console.log("Error writing config file: " + err);
        return false;
    }

    return file;
}

/*
 * Create parameters to workflow
 */
function getInDir() {
    let dir = document.querySelector('#indir').value;
    // let outdir = "S:\\LAB_JVC\\RESULTADOS\\JM RC\\iq-Proteo\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_Fraccionamiento";
    try {
        if (!fs.existsSync(dir)){
            console.log("Input directory does not exist");
            return false;
        }
    } catch (err) {    
        console.log("Error getting input directory: " + err);
        return false;
    }
    return dir;
}
function createLocalDir() {
    let dir = document.querySelector('#outdir').value;
    // let dir = "S:\\LAB_JVC\\RESULTADOS\\JM RC\\iq-Proteo\\WF";
    try {
        if (!fs.existsSync(dir)){
            fs.mkdirSync(dir);
        }
    } catch (err) {    
        console.log("Error creating local directory: " + err);
        return false;
    }
    return dir;
}
function getModificationFile() {
    let file = document.querySelector('#modfile').value;
    // let file = "D:/projects/iq-Proteo/src/pRatio/modifications.xml";
    try {
        if (!fs.existsSync(file)){
            console.log("Modification file does not exist");
            return false;
        }
    } catch (err) {    
        console.log("Error getting modification file: " + err);
        return false;
}
    return file;
}
function getCategoryFile() {
    let file = document.querySelector('#catfile').value;
    // let file = "S:/U_Proteomica/PROYECTOS/PESA_omicas/AteroPreclin_140_V1/Proteomics/Resultados/scripts-miscelaneas/q2cIPA-DAVID-CORUM-Manual-Human3_nd.txt";
    try {
        if (!fs.existsSync(file)){
            console.log("Category file does not exist");
            return false;
        }
    } catch (err) {    
        console.log("Error getting category file: " + err);
        return false;
}
    return file;
}
function createParameters() {
    let params = {};

    // get input directory
    let indir = getInDir();
    if ( !indir ) {
        exceptor.showMessageBox('Error Message', 'Input directory is required');
        return false;
    }
    else { params.indir = indir }

    // get and create check and get: output directory
    let outdir = createLocalDir();
    if ( !outdir ) {
        exceptor.showMessageBox('Error Message', 'Output directory is required');
        return false;
    }
    else { params.outdir = outdir }

    // create datatable file
    let dtablefile = createDatatableFile(outdir); 
    if ( !dtablefile ) {
        exceptor.showMessageBox('Error Message', 'Creating datatable file');
        return false;
    }

    let modfile = getModificationFile();
    if ( !modfile ) {
        exceptor.showMessageBox('Error Message', 'Modification file is required');
        return false;
    }

    let catfile = getCategoryFile();
    if ( !catfile ) {
        exceptor.showMessageBox('Error Message', 'Category file is required');
        return false;
    }

    // check and retrieve: workflow template
    let conf = remote.app.getAppPath() + '/templates/conf-wo_out.json'

    // Create Config file
    let cfgfile = createConfFile(conf, indir, outdir, dtablefile, modfile, catfile);
    if ( !cfgfile ) {
        exceptor.showMessageBox('Error Message', 'Creating config file');
        return false;
    }
    else { params.cfgfile = cfgfile }

    // get: num threads
    params.nthreads = document.querySelector('#nthreads').value;

    return params;
}

// We assign properties to the `module.exports` property, or reassign `module.exports` it to something totally different.
// In  the end of the day, calls to `require` returns exactly what `module.exports` is set to.
module.exports.createParameters = createParameters;



/*
 * Events
 */

// for Database
document.getElementById('select-indir').addEventListener('click', function(){
    dialog.showOpenDialog({ properties: ['openDirectory']}, function (dirs) {
        if(dirs === undefined){
            console.log("No input directory selected");
        } else{
            document.getElementById("indir").value = dirs[0];
        }
    }); 
},false);
document.getElementById('select-outdir').addEventListener('click', function(){
    dialog.showOpenDialog({ properties: ['openDirectory']}, function (dirs) {
        if(dirs === undefined){
            console.log("No output directory selected");
        } else{
            document.getElementById("outdir").value = dirs[0];
        }
    }); 
},false);

// for pRatio
document.getElementById('select-modfile').addEventListener('click', function(){
    dialog.showOpenDialog({ properties: ['openFile']}, function (files) {
        if(files === undefined){
            console.log("No modification file selected");
        } else{
            document.getElementById("modfile").value = files[0];
        }
    }); 
},false);

// for SanXot
document.getElementById('select-catfile').addEventListener('click', function(){
    dialog.showOpenDialog({ properties: ['openFile']}, function (files) {
        if(files === undefined){
            console.log("No category file selected");
        } else{
            document.getElementById("catfile").value = files[0];
        }
    }); 
},false);

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
function addConfParams(file, dtable) {
    // get object from template
    let data = JSON.parse(file);

    // add tabledata file
    data['indata'] = dtable;


    // add category
    data['catfile'] = "S:/U_Proteomica/PROYECTOS/PESA_omicas/AteroPreclin_140_V1/Proteomics/Resultados/scripts-miscelaneas/q2cIPA-DAVID-CORUM-Manual-Human3_nd.txt";
    
    return data;
}

function createConfFile(conf, outdir, dtable) {

    // read template file
    try {
        //file exists, get the contents
        let d = fs.readFileSync(conf);

        // create config data with the parameters
        let data = addConfParams(d, dtable);

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
function createParameters() {
    let params = {};

    // check and get: output directory
    let outdir = document.querySelector('#outdir').value;
    outdir = "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test";
    if ( outdir === "" ) {
        exceptor.showMessageBox('Error Message', 'Output directory is required');
        return false;
    }

    // create datatable file
    let dtablefile = createDatatableFile(outdir); 
    if ( !dtablefile ) {
        exceptor.showMessageBox('Error Message', 'Creating datatable file');
        return false;
    }

    // check and retrieve: workflow template
    let conf = remote.app.getAppPath() + '/templates/conf-wo_out.json'

    // Create Config file
    let cfgfile = createConfFile(conf, outdir, dtablefile);
    if ( !cfgfile ) {
        exceptor.showMessageBox('Error Message', 'Creating config file');
        return false;
    }
    else { params.cfgfile = cfgfile }

    // get: num threads
    params.nthreads = document.querySelector('#nthreads').value;

    return params;
}

/*
 * Events
 */

document.getElementById('select-outdir').addEventListener('click', function(){
    dialog.showOpenDialog({ properties: ['openDirectory']}, function (dirs) {
        if(dirs === undefined){
            console.log("No output directory selected");
        } else{
            document.getElementById("outdir").value = dirs[0];
        }
    }); 
},false);


// We assign properties to the `module.exports` property, or reassign `module.exports` it to something totally different.
// In  the end of the day, calls to `require` returns exactly what `module.exports` is set to.
module.exports.createParameters = createParameters;



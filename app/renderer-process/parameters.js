/*
 * Handle parameters
 */
let remote = require('electron').remote;
let dialog = remote.dialog;

/*
 * Check the parameters
 */

// check all parameters
function checkParams() {
    let params = {};

    // check and get: output directory
    let outdir = document.querySelector('#actual-folder').value;
    //  outdir = "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test";
    if ( outdir === "" ) {
        exceptor.showMessageBox('Error Message', 'Output directory is required.');
        return false;    
    }
    else { params.outdir = outdir }

    // check and get: num threads
    let execparams = {};
    params.nthreads = document.querySelector('#nthreads').value;

    // check and retrieve: workflow template
    params.conf = remote.app.getAppPath() + '/templates/conf-wo_out.json'

    return params;
};

// create the parameters
function createParameters() {
    let params = {};

    // Create Config file
    let conffile = parameters.createConfFile(params.conf, params.outdir);


    // check the quantification parameters
    params.quantparams = checkQuantparams();

    // check and get: num threads
    let execparams = {};
    execparams.nthreads = document.querySelector('#nthreads').value;

    // merge parameter values
    let params = {quantparams, execparams};

    return params;
}

/*
 * Events
 */

document.getElementById('select-folder').addEventListener('click',function(){
    dialog.showOpenDialog({ properties: ['openDirectory']}, function (fileNames) {
        if(fileNames === undefined){
            console.log("No file selected");
        } else{
            document.getElementById("actual-folder").value = fileNames[0];
        }
    }); 
},false);


// We assign properties to the `module.exports` property, or reassign `module.exports` it to something totally different.
// In  the end of the day, calls to `require` returns exactly what `module.exports` is set to.
module.exports.createParameters = createParameters;



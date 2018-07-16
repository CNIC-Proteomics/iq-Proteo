/*
 * Check the parameters
 */

let remote = require('electron').remote;

// check the SanXoT parameters
function Quantparams() {
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
  params.nthreads = 10;

  // check and retrieve: workflow template
  params.conf = remote.app.getAppPath() + '/templates/conf-wo_out.json'


  return params;
};


// We assign properties to the `module.exports` property, or reassign `module.exports` it to something totally different.
// In  the end of the day, calls to `require` returns exactly what `module.exports` is set to.
module.exports.Quantparams = Quantparams;


function appendToDroidOutput(msg) { getDroidOutput().value += msg; };
function setStatus(msg)           { getStatus().innerHTML = msg; };

let fs = require('fs');

function backgroundProcess(cmd) {
  "use strict";
  // The path to the .bat file
  // var myBatFilePath = 'D:/projects/qProteo/venv_win64/venv_win64_py3x/Scripts/activate.bat && snakemake.exe --configfile "S:/LAB_JVC/RESULTADOS/JM RC/qProteo/test/test3-conf.pesa.json" --snakefile "D:/projects/qProteo/qproteo.smk" --unlock && snakemake.exe --configfile "S:/LAB_JVC/RESULTADOS/JM RC/qProteo/test/test3-conf.pesa.json" --snakefile "D:/projects/qProteo/qproteo.smk" -j 20 --rerun-incomplete';
  // console.log( myBatFilePath )

// const spawn = require('child_process').spawn;
// const bat = spawn('cmd.exe', ['/c', '/s', myBatFilePath]);


// // Handle normal output
// bat.stdout.on('data', (data) => {
//     // As said before, convert the Uint8Array to a readable string.
//     var str = String.fromCharCode.apply(null, data);
//     console.info(str);
//     appendToDroidOutput(str);
// });

// // Handle error output
// bat.stderr.on('data', (data) => {
//     // As said before, convert the Uint8Array to a readable string.
//     var str = String.fromCharCode.apply(null, data);
//     console.error(str);
//     appendToDroidOutput(str);
// });

// // Handle on exit event
// bat.on('exit', (code) => {
//     var preText = `Child exited with code ${code} : `;

//     switch(code){
//         case 0:
//             console.info(preText+"Something unknown happened executing the batch.");
//             break;
//         case 1:
//             console.info(preText+"The file already exists");
//             break;
//         case 2:
//             console.info(preText+"The file doesn't exists and now is created");
//             break;
//         case 3:
//             console.info(preText+"An error ocurred while creating the file");
//             break;
//     }
// });


// const { exec } = require('child_process');
// exec(myBatFilePath, (error, stdout, stderr) => {
//   if (error) {
//     console.error(`exec error: ${error}`);
//     appendToDroidOutput(str);
//     return;
//   }
//   appendToDroidOutput(stdout);
//   appendToDroidOutput(stderr);
//   console.log(`stdout: ${stdout}`);
//   console.log(`stderr: ${stderr}`);
// });


  // const { spawn } = require('child_process');
  // const ls = spawn( myBatFilePath );
  const { exec } = require('child_process');
  const ls = exec( cmd );

  ls.stdout.on('data', (data) => {
      appendToDroidOutput(data);
          console.log(`stdout: ${data}`);
  });

  ls.stderr.on('data', (data) => {
    appendToDroidOutput(data);
    console.log(`stderr: ${data}`);
  });

  ls.on('close', (code) => {
    console.log(`child process exited with code ${code}`);
  });

};

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
  let datatable = $("#hot").data('handsontable');

  let file = outdir + '/iq-proteo_data.csv';
  if (file === undefined) {
    throw("You didn't save the file");
  }

  // export Datatable to CSV
  try {
    var cont = exportDatatableCSV(datatable);
  } catch (err) {
    //if error
    throw("Error exporting datatable: " + err);
  }

  // write file sync
  try {
    fs.writeFileSync(file, cont, 'utf-8');
  } catch (err) {    
    throw("Error writing datatable file: " + err);
  }

  return file;
};


/*
 * Create config file 
 */
function createConfFile(conf, outdir) {

  let file = outdir + '/iq-proteo_conf.json';
  if (file === undefined) {
      console.log("You didn't save the file");
      return;
  }

  // read template file
  try {
    let d = fs.readFileSync(conf); //file exists, get the contents
    let data = JSON.parse(d);
    data['indata'] = "MIERDA";
    var cont = JSON.stringify(data, undefined, 2);
  } catch (err) {
    //if error
    console.log("Error creating config file: " + err);
    return;
  }

  // write file sync
  try {
    fs.writeFileSync(file, cont, 'utf-8');
  } catch (err) {    
    console.log("Error writing config file: " + err);
    return;
  }

  // Create Datatable file
  createDatatableFile(outdir); 

  return file;
};

/*
 * Click Executor
 */
document.getElementById('executor').addEventListener('click', function() {

  // Check and retrieves parameters
  let params = parameters.checkParams();
  if ( params ) {    
    // Create Config file
    let conffile = parameters.createConfFile(params.conf, params.outdir);

    // Execute the workflow
    if ( conffile !== undefined ) {
      let cmd = 'D:/projects/qProteo/venv_win64/venv_win64_py3x/Scripts/activate.bat && ';
      cmd += 'snakemake.exe --configfile "'+conffile+'" --snakefile "D:/projects/qProteo/qproteo.smk" --unlock && ';
      cmd += 'snakemake.exe --configfile "'+conffile+'" --snakefile "D:/projects/qProteo/qproteo.smk" -j '+params.nthreads+' --rerun-incomplete';
      alert( cmd );
      // backgroundProcess( cmd );  
    }
    else {
      alert("Error creating config file");
    }  
  }

});


function appendToDroidOutput(msg) { getDroidOutput().value += msg; };
function setStatus(msg)           { getStatus().innerHTML = msg; };

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
    // console.log(`stdout: ${data}`);
  });

  ls.stderr.on('data', (data) => {
    exceptor.showMessageBox('Error Running the workflow', data);
    appendToDroidOutput(data);
    console.log(`stderr: ${data}`);
  });

  ls.on('close', (code) => {
    console.log(`child process exited with code ${code}`);
  });

};

/*
 * Click Executor
 */
document.getElementById('executor').addEventListener('click', function() {

  // Check and retrieves parameters
  let params = parameters.createParameters();
  if ( params ) {

    // Execute the workflow
    let smkfile = process.env.IQPROTEO_HOME + '/qproteo.smk';
    let cmd = process.env.IQPROTEO_HOME + '/venv_win64/venv_win64_py3x/Scripts/activate.bat && ';
    cmd += 'snakemake.exe --configfile "'+params.cfgfile+'" --snakefile "'+smkfile+'" --unlock && ';
    cmd += 'snakemake.exe --configfile "'+params.cfgfile+'" --snakefile "'+smkfile+'" -j '+params.nthreads+' --rerun-incomplete';
    console.log( cmd );
    backgroundProcess( cmd );
  }

});

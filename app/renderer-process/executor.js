const { ipcRenderer } = require('electron');

/*
  Global variables
*/
let cProcess = require('child_process');
let psTree = require(process.env.IQPROTEO_NODE_PATH + '/ps-tree')
let proc = null;


function appendToDroidOutput(msg) {
  let elem = document.getElementById("droid-output"); 
  elem.value += msg;
}

function backgroundProcess(cmd) {
  // eexecute command line
  proc = cProcess.exec( cmd );

  // send the process id to main js
  ipcRenderer.send('pid-message', proc.pid);

  // psTree(proc.pid, function (err, children) {  // check if it works always
  //   children.map(function (p) {
  //     console.log( 'Process %s has been killed!', p.PID );
  //     // ipcRenderer.send('pid-message', p.PID );
  //     // process.kill(p.PID);           
  //   });
  // });


  // psTree(proc.pid, function (err, children) {  // check if it works always
  //   children.map(function (p) {
  //     console.log( 'Process %s has been killed!', p.PID );
  //     ipcRenderer.send('pid-message', p.PID );
  //     process.kill(p.PID);                
  //   });
  // });


  proc.stdout.on('data', (data) => {
    appendToDroidOutput(data);
    // console.log(`stdout: ${data}`);
  });

  proc.stderr.on('data', (data) => {
    appendToDroidOutput(data);
    console.log(`stderr: ${data}`);
  });

  // Handle on exit event
  proc.on('close', (code) => {
    var preText = `Child exited with code ${code} : `;
    switch(code){
        case 0:
            console.info(preText+"Something unknown happened executing the batch.");
            break;
        case 1:
            console.info(preText+"The file already exists");
            break;
        case 2:
            console.info(preText+"The file doesn't exists and now is created");
            break;
        case 3:
            console.info(preText+"An error ocurred while creating the file");
            break;
    }
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
    // let smkfile = process.env.IQPROTEO_SRC_HOME + '/qproteo.smk';
    let smkfile = tasktable.smkfile;
    let cmd_smk = '"'+process.env.IQPROTEO_PYTHON3x_HOME + '/tools/Scripts/snakemake.exe" --configfile "'+params.cfgfile+'" --snakefile "'+smkfile+'" -j '+params.nthreads+' -d "'+params.outdir+'" ';
    let cmd = cmd_smk+' --unlock && '+cmd_smk+' --rerun-incomplete ';

    // let cmd_smk = 'snakemake.exe --configfile "'+params.cfgfile+'" --snakefile "'+smkfile+'" -j '+params.nthreads+' -d "'+params.outdir+'" ';
    // let cmd = '"'+process.env.IQPROTEO_LIB_HOME + '/python_venv/Scripts/activate.bat" && ';
    // cmd += cmd_smk+' --unlock && ';
    // cmd += cmd_smk+' --rerun-incomplete ';
    console.log( cmd );
    backgroundProcess( cmd );

    // active the log tab
    $('.nav-tabs a#processes-tab').tab('show');

    // disable Start button
    document.getElementById('executor').disabled = true;
  }

});

// Kill all shell processes
document.getElementById('stopproc').addEventListener('click', function() {
  if ( proc != null ) {
    let sms = "Look for child processes from: "+proc.pid+"\n";
    console.log(sms);
    appendToDroidOutput("\n\nThe processes have been stopped!\n\n");
    psTree(proc.pid, function (err, children) {  // check if it works always
      children.forEach(function (p) {
        let sms = "Process has been killed!"+p.PID+"\n";
        console.log(sms);
        process.kill(p.PID); 
      });
      // enable the Start button
      document.getElementById('executor').disabled = false;
    });
  }
});

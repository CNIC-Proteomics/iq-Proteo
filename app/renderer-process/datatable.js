/*
  Global variables
*/

// const { dialog } = require('electron');
// let remote = require('electron').remote; 
// let dialog = remote.dialog;

let data = [
[
    "TMT1",
    "wt 1",
    "126",
    "",
    ""
],
[
    "TMT1",
    "wt 2",
    "127_N",
    "127_N",
    "126,131"
],
[
    "TMT1",
    "wt 3",
    "127_C",
    "127_C",
    "126,131"
],
[
    "TMT1",
    "wt 4",
    "128_N",
    "128_N",
    "126,131"
],[
    "TMT1",
    "KO 1",
    "128_C",
    "128_C",
    "126,131"
],[
    "TMT1",
    "KO 2",
    "129_N",
    "129_N",
    "126,131"
],[
    "TMT1",
    "KO3",
    "129_C",
    "129_C",
    "126,131"
],[
    "TMT1",
    "KO4",
    "130_N",
    "130_N",
    "126,131"
],[
    "TMT1",
    "h34571",
    "130_C",
    "130_C",
    "126,131"
],[
    "TMT1",
    "h34572",
    "131",
    "131",
    "126,131"
],
[
    "TMT2",
    "wt 1",
    "126",
    "",
    ""
],
[
    "TMT2",
    "wt 2",
    "127_N",
    "127_N",
    "126,131"
],
[
    "TMT2",
    "wt 3",
    "127_C",
    "127_C",
    "126,131"
],
[
    "TMT2",
    "wt 4",
    "128_N",
    "128_N",
    "126,131"
],[
    "TMT2",
    "KO 1",
    "128_C",
    "128_C",
    "126,131"
],[
    "TMT2",
    "KO 2",
    "129_N",
    "129_N",
    "126,131"
],[
    "TMT2",
    "KO3",
    "129_C",
    "129_C",
    "126,131"
],[
    "TMT2",
    "KO4",
    "130_N",
    "130_N",
    "126,131"
],[
    "TMT2",
    "h34571",
    "130_C",
    "130_C",
    "126,131"
],[
    "TMT2",
    "h34572",
    "131",
    "131",
    "126,131"
]
];
let header = ["experiment", "name", "tag", "ratio_numerator", "ratio_denominator"];

let container = $('#hot').handsontable({
data: data,
colHeaders: header,
minRows: 1,
minCols: 2,
minSpareRows: 1,
rowHeaders: true,
contextMenu: true,
manualColumnResize: true,
// formulas: true,
// manualRowMove: true,
// manualColumnMove: true,
// filters: true,
// dropdownMenu: true,
// mergeCells: true,
// columnSorting: true,
// sortIndicator: true,
autoColumnSize: {
    samplingRatio: 23
}
// fixedRowsTop: 2,
// fixedColumnsLeft: 3        
});


// /*
//  * Events
//  */

// document.getElementById('select-indir').addEventListener('click', function(){
//     dialog.showOpenDialog({ properties: ['openDirectory']}, function (dirs) {
//         if(dirs === undefined){
//             console.log("No input directory selected");
//         } else{
//             document.getElementById("indir").value = dirs[0];
//         }
//     }); 
// },false);
// document.getElementById('select-outdir').addEventListener('click', function(){
//     dialog.showOpenDialog({ properties: ['openDirectory']}, function (dirs) {
//         if(dirs === undefined){
//             console.log("No output directory selected");
//         } else{
//             document.getElementById("outdir").value = dirs[0];
//         }
//     }); 
// },false);

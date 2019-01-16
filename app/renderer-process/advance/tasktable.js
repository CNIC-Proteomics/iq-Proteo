/*
  Global variables
*/

// let header = ["experiment", "name", "tag", "ratio_numerator", "ratio_denominator", "s>p FDR", "p>q FDR", "q>c FDR","s>p FDR", "p>q FDR", "q>c FDR"];
let header = ["experiment", "name", "tag", "ratio_numerator", "ratio_denominator", "s>p FDR", "p>q FDR", "q>c FDR","s>p FDR", "p>q FDR", "q>c FDR"];

// nestedHeaders: [
//   ['A', {label: 'B', colspan: 8}, 'C'],
//   ['D', {label: 'E', colspan: 4}, {label: 'F', colspan: 4}, 'G'],
//   ['H', {label: 'I', colspan: 2}, {label: 'J', colspan: 2}, {label: 'K', colspan: 2}, {label: 'L', colspan: 2}, 'M'],
//   ['N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W']
// ]

let dtatest = [
  ["TMT1","wt 1","126","",""],
  ["TMT1","wt 2","127_N","127_N","126,131"],
  ["TMT1","wt 3","127_C","127_C","126,131"],
  ["TMT1","wt 4","128_N","128_N","126,131"],
  ["TMT1","KO 1","128_C","128_C","126,131"],
  ["TMT1","KO 2","129_N","129_N","126,131"],
  ["TMT1","KO3","129_C","129_C","126,131"],
  ["TMT1","KO4","130_N","130_N","126,131"],
  ["TMT1","h34571","130_C","130_C","126,131"],
  ["TMT1","h34572","131","131","126,131"],
  ["TMT2","wt 1","126","",""],
  ["TMT2","wt 2","127_N","127_N","126,131"],
  ["TMT2","wt 3","127_C","127_C","126,131"],
  ["TMT2","wt 4","128_N","128_N","126,131"],
  ["TMT2","KO 1","128_C","128_C","126,131"],
  ["TMT2","KO 2","129_N","129_N","126,131"],
  ["TMT2","KO3","129_C","129_C","126,131"],
  ["TMT2","KO4","130_N","130_N","126,131"],
  ["TMT2","h34571","130_C","130_C","126,131"],
  ["TMT2","h34572","131","131","126,131"]
];
  
let dtatest2 = [
  ["Calseq2","wt 1","126","",""],
  ["Calseq2","wt 2","127_N","127_N","126,131"],
  ["Calseq","wt 3","127_C","127_C","126,131"],
  ["Calseq","wt 4","128_N","128_N","126,131"],
  ["Calseq","wt 5","128_C","128_C","126,131"],
  ["Calseq","KO 1","129_N","129_N","126,131"],
  ["Calseq","KO 2","129_C","129_C","126,131"],
  ["Calseq","KO 3","130_N","130_N","126,131"],
  ["Calseq","KO 4","130_C","130_C","126,131"],
  ["Calseq","KO 5","131","131","126,131"],
];

let container = $('#hot').handsontable({
data: [[]],
colHeaders: header,
// colHeaders: true,
// nestedHeaders: header,
minRows: 2,
minCols: header.length,
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

let smkfile = process.env.IQPROTEO_SRC_HOME + '/wfs/advance.smk';

// We assign properties to the `module.exports` property, or reassign `module.exports` it to something totally different.
// In  the end of the day, calls to `require` returns exactly what `module.exports` is set to.
module.exports.smkfile = smkfile;
module.exports.dtatest = dtatest;
module.exports.dtatest2 = dtatest2;
module.exports.container = container;
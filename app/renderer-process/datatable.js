
let data = [
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "wt 1",
    "126",
    "",
    ""
],
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "wt 2",
    "127_N",
    "127_N",
    "126,131"
],
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "wt 3",
    "127_C",
    "127_C",
    "126,131"
],
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "wt 4",
    "128_N",
    "128_N",
    "126,131"
],[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "KO 1",
    "128_C",
    "128_C",
    "126,131"
],[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "KO 2",
    "129_N",
    "129_N",
    "126,131"
],[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "KO3",
    "129_C",
    "129_C",
    "126,131"
],[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "KO4",
    "130_N",
    "130_N",
    "126,131"
],[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "h34571",
    "130_C",
    "130_C",
    "126,131"
],[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1\\MSF",
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento\\TMT1",
    "TMT1",
    "h34572",
    "131",
    "131",
    "126,131"
]

];
let header = ["msfdir", "idedir", "experiment", "name", "tag", "ratio_numerator", "ratio_denominator"];

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

// // Export Datatable to CSV
// // function parseRow(infoArray, index, csvContent) {
// // var sizeData = _.size(container.data('handsontable').getData());
// // if (index < sizeData - 1) {
// //     dataString = "";
// //     _.each(infoArray, function(col, i) {
// //     dataString += _.contains(col, ",") ? "\"" + col + "\"" : col;
// //     dataString += i < _.size(infoArray) - 1 ? "," : "";
// //     })

// //     csvContent += index < sizeData - 2 ? dataString + "\n" : dataString;
// // }
// // return csvContent;
// // }
// function parseRow(infoArray, index, csvContent) {
//     let data = container.data('handsontable').getData();
//     let sizeData = data.length;
//     if (index < sizeData - 1) {
//         dataString = "";
//             infoArray.forEach(function(col,i) {            
//             dataString += _.contains(col, ",") ? "\"" + col + "\"" : col;
//             dataString += i < _.size(infoArray) - 1 ? "," : "";
//         })
//         csvContent += index < sizeData - 2 ? dataString + "\n" : dataString;
//     }
//     return csvContent;
// }

// function exportDatatableCSV () {
//     let csvContent = "datahandsontable:text/csv;charset=utf-8,";
//     let data = container.data('handsontable').getData();
//     // csvContent = parseRow(header, 0, csvContent);
//     data.forEach(function(row,idx) {
//         csvContent = parseRow(row, idx, csvContent);
//     });    
//     console.log(csvContent);
//     //   _.each(container.data('handsontable').getData(), function(infoArray, index) {
// //     csvContent = parseRow(infoArray, index, csvContent);
// //   });
// //   var encodedUri = encodeURI(csvContent);
// //   var link = document.createElement("a");
// //   link.setAttribute("href", encodedUri);
// //   link.setAttribute("download", $("h1").text() + ".csv");
// //   link.click();
// }
// document.querySelector('#export-csv').addEventListener('click', exportDatatableCSV)

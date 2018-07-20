
let data = [
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "wt 1",
    "126",
    "",
    ""
],
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "wt 2",
    "127_N",
    "127_N",
    "126,131"
],
[
    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "wt 3",
    "127_C",
    "127_C",
    "126,131"
],
[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "wt 4",
    "128_N",
    "128_N",
    "126,131"
],[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "KO 1",
    "128_C",
    "128_C",
    "126,131"
],[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "KO 2",
    "129_N",
    "129_N",
    "126,131"
],[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "KO3",
    "129_C",
    "129_C",
    "126,131"
],[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "KO4",
    "130_N",
    "130_N",
    "126,131"
],[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "h34571",
    "130_C",
    "130_C",
    "126,131"
],[

    "S:\\LAB_JVC\\RESULTADOS\\JM RC\\qProteo\\test\\PESA_omicas\\3a_Cohorte_120_V2\\TMT_sin_fraccionamiento",
    "TMT1",
    "h34572",
    "131",
    "131",
    "126,131"
]

];
let header = ["idedir", "experiment", "name", "tag", "ratio_numerator", "ratio_denominator"];

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

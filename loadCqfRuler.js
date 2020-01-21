const program = require('commander');
const fs = require('fs');
const { FHIRClient } = require('fhir-crud-client');
const path = require('path');
const _ = require('lodash');

program
  .option('-u --url <url>', 'Base URL of running cqf-ruler instance', 'http://localhost:8080/cqf-ruler-dstu3/fhir')
  .option('-m --measure <measure>', 'Measure directory containing outputted patients and MeasureReport')
  .parse(process.argv);

if (!program.url) throw new Error('-u/--url required');
if (!program.measure) throw new Error('-m/--measure required');

const outputPath = path.join(__dirname, `./${program.measure}/output`);
const outputDirs = fs.readdirSync(outputPath, 'utf8');
const uploadPath = path.join(outputPath, _.max(outputDirs, d => fs.statSync(d).ctime));
const ipopPath = path.join(uploadPath, 'ipop');
const numerPath = path.join(uploadPath, 'numerator');
const denomPath = path.join(uploadPath, 'denominator');
const mrPath = path.join(uploadPath, 'measure-report.json');

const client = new FHIRClient(program.url);

(async () => {
  let transactions = [];
  if (fs.existsSync(mrPath)) {
    const measureReport = fs.readFileSync(mrPath, 'utf8');
    transactions.push(client.create({ resourceType: 'MeasureReport', body: JSON.parse(measureReport) }));
  }

  [ipopPath, numerPath, denomPath].forEach(p => {
    const bundles = fs.readdirSync(p).map(b => JSON.parse(fs.readFileSync(path.join(p, b), 'utf8')));
    transactions = transactions.concat(bundles.map(b => client.transaction({ body: b })));
  });

  try {
    await Promise.all(transactions);
  } catch (e) {
    console.error(e.data);
    throw new Error(e.message);
  }
})();

const fs = require("fs");
const path = require("path");
const { Calculator } = require("fqm-execution");

const dir = process.argv[2];

console.log("checking fpg patients");
if (!dir || dir === "all") {
  fs.readdirSync(".")
    .filter((s) => fs.lstatSync(s).isDirectory())
    .filter((d) => d.startsWith("EXM"))
    .forEach((d) => checkMeasure(d));

  testCthonMeasure(
    "EXM74-10.2.000",
    "tests-numer-strat1-EXM74-bundle.json",
    "tests-denom-EXM74-bundle.json"
  );

  testCthonMeasure(
    "EXM153-9.2.000",
    "tests-numer-strat1-EXM153-bundle.json",
    "tests-denom-EXM153-bundle.json"
  );
} else if (dir === "cthon") {
  testCthonMeasure(
    "EXM74-10.2.000",
    "tests-numer-strat1-EXM74-bundle.json",
    "tests-denom-EXM74-bundle.json"
  );

  testCthonMeasure(
    "EXM153-9.2.000",
    "tests-numer-strat1-EXM153-bundle.json",
    "tests-denom-EXM153-bundle.json"
  );
} else {
  checkMeasure(dir);
}

function testCthonMeasure(measureId, numerPatientName, denomPatientName) {
  console.log(`checking connectathon patients for ${measureId}`);
  const measureBundleBasePath = `./connectathon/fhir401/bundles/${measureId}`;
  const measureBundlePath = path.join(
    measureBundleBasePath,
    `${measureId}-bundle.json`
  );
  const measureBundle = JSON.parse(fs.readFileSync(measureBundlePath, "utf8"));

  const numerPatientPath = path.join(
    measureBundleBasePath,
    `${measureId}-files/${numerPatientName}`
  );
  const denomPatientPath = path.join(
    measureBundleBasePath,
    `${measureId}-files/${denomPatientName}`
  );

  const numerPatient = JSON.parse(fs.readFileSync(numerPatientPath, "utf8"));
  const denomPatient = JSON.parse(fs.readFileSync(denomPatientPath, "utf8"));

  const numerResults = getResults(measureBundle, numerPatient);
  if (
    !check(
      measureId,
      numerResults,
      { ipop: true, denom: true, numer: true },
      numerPatientName
    )
  ) {
    return;
  }

  const denomResults = getResults(measureBundle, denomPatient);
  if (
    !check(
      measureId,
      denomResults,
      { ipop: true, denom: true, numer: false },
      denomPatientName
    )
  ) {
    return;
  }
  console.log(`${measureId} - all checks passed`);
  return;
}

function getPatient(basePath) {
  if (!fs.existsSync(basePath)) return null;
  const name = fs.readdirSync(basePath)[0];
  const bundle = JSON.parse(fs.readFileSync(path.join(basePath, name), "utf8"));

  return {
    name,
    bundle,
  };
}

function getResults(mBundle, pBundle) {
  const res = Calculator.calculate(mBundle, [pBundle], {});
  const popResults = res[0].detailedResults[0].populationResults;

  const ipop = popResults.find((r) => r.populationType === "initial-population")
    .result;
  const denom = popResults.find((r) => r.populationType === "denominator")
    .result;
  const numer = popResults.find((r) => r.populationType === "numerator").result;

  return {
    ipop,
    denom,
    numer,
  };
}

function throwError(measureDir, pName, pop, desiredResult) {
  console.error(
    `${measureDir} - Error: Patient ${pName} expected in ${pop} = ${desiredResult} but result was ${!desiredResult}`
  );
}

function check(measureDir, results, desiredResults, name) {
  let retval = true;
  if (results.ipop !== desiredResults.ipop) {
    throwError(measureDir, name, "initial population", desiredResults.ipop);
    retval = false;
  }
  if (results.denom !== desiredResults.denom) {
    throwError(measureDir, name, "denominator", desiredResults.denom);
    retval = false;
  }
  if (results.numer !== desiredResults.numer) {
    throwError(measureDir, name, "numerator", desiredResults.numer);
    retval = false;
  }

  return retval;
}

function checkMeasure(measureDir) {
  const cthonDir = measureDir.replace("_", ""); // match connectathon file path naming

  const measureBundlePath = `./connectathon/fhir401/bundles/${cthonDir}/${cthonDir}-bundle.json`;
  const measureBundle = JSON.parse(fs.readFileSync(measureBundlePath, "utf8"));

  const patientBasePath = `./${measureDir}/patients-r4`;

  const numPath = path.join(patientBasePath, "/numerator");
  const denomPath = path.join(patientBasePath, "/denominator");
  const ipopPath = path.join(patientBasePath, "/ipop");

  const firstNumer = getPatient(numPath);
  const firstDenom = getPatient(denomPath);
  const firstIpop = getPatient(ipopPath);

  if (firstNumer) {
    const firstNumerResults = getResults(measureBundle, firstNumer.bundle);

    if (
      !check(
        measureDir,
        firstNumerResults,
        { ipop: true, denom: true, numer: true },
        firstNumer.name
      )
    ) {
      return;
    }
  }

  if (firstDenom) {
    const firstDenomResults = getResults(measureBundle, firstDenom.bundle);

    if (
      !check(
        measureDir,
        firstDenomResults,
        { ipop: true, denom: true, numer: false },
        firstDenom.name
      )
    ) {
      return;
    }
  }

  if (firstIpop) {
    const firstIpopResults = getResults(measureBundle, firstIpop.bundle);

    if (
      !check(
        measureDir,
        firstIpopResults,
        { ipop: true, denom: false, numer: false },
        firstIpop.name
      )
    ) {
      return;
    }
  }
  console.log(`${measureDir} - all checks passed`);
}

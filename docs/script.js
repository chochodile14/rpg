fetch("version.json")
.then(r=>r.json())
.then(data=>{

document.getElementById("version").innerText="Version : "+data.version;

document.getElementById("date").innerText="Dernière mise à jour : "+data.date;

document.getElementById("download").href=data.download;

});
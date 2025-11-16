document.getElementById('btn').addEventListener('click', function(self) {
    self.preventDefault();
    var membro = document.getElementById('membro').value;
    var artigo = document.getElementById('artigo').value;
    var quantidade = parseInt(document.getElementById('quantidade').value, 10);
    var data = document.getElementById('data').value;
    var receptor = document.getElementById('receptor').value;
    var obs = document.getElementById('obs').value;
    var payload = {
        'membro': membro,
        'artigo': artigo,
        'quantidade': quantidade,
        'data': data,
        'receptor': receptor,
        'obs': obs
    }
    fetch("http://localhost:8081/form-cautela", {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload)
    }).then(function(resp) {return resp.json();})
    .then(function(payload){
        console.log(payload);
    })
})
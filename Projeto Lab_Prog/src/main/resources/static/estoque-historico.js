function carregarSubmissoes() {
    fetch("http://localhost:8081/submissoes")
      .then(resp => resp.json())
      .then(lista => {
        const tbody = document.getElementById("tabela-submissoes");
        tbody.innerHTML = ""; // limpa antes
  
        lista.forEach(item => {
          const tr = document.createElement("tr");
  
          tr.innerHTML = `
            <td>${item.membro}</td>
            <td>${item.artigo}</td>
            <td>${item.quantidade}</td>
            <td>${item.data}</td>
            <td>${item.receptor}</td>
            <td>${item.obs || ""}</td>
          `;
  
          tbody.appendChild(tr);
        });
      })
      .catch(err => console.error("Erro ao carregar submissões:", err));
  }
  
  // chama quando a página carregar
  window.addEventListener("load", carregarSubmissoes);
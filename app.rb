# ============================================================
#  BACK-END — app.rb
#  Framework: Sinatra (servidor web leve para Ruby)
#  Este arquivo é o coração da aplicação. Ele:
#    1. Sobe um servidor web na porta 4567
#    2. Serve o arquivo HTML para o navegador
#    3. Recebe os dados enviados pelo front-end via JSON
#    4. Processa toda a lógica Ruby
#    5. Devolve os resultados em JSON para o front-end exibir
# ============================================================

require 'sinatra'        # Biblioteca que cria o servidor web
require 'json'           # Biblioteca para trabalhar com JSON

# ── Configurações do servidor ──────────────────────────────
set :port, 4567          # Porta onde o servidor vai rodar
set :public_folder, 'public'  # Pasta onde fica o arquivo HTML

# Habilita CORS para permitir comunicação entre front e back
before do
  response.headers['Access-Control-Allow-Origin']  = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  content_type :json       # Todas as respostas serão em JSON
end

# Responde às requisições OPTIONS (necessário para CORS)
options '*' do
  200
end

# ── Rota principal ─────────────────────────────────────────
# Quando o usuário abre http://localhost:4567 no navegador,
# o Sinatra serve automaticamente o public/index.html
get '/' do
  content_type :html
  send_file File.join(settings.public_folder, 'index.html')
end


# ============================================================
# EXERCÍCIO 1 — Boas-vindas
# Recebe: { "nome": "Maria" }
# Valida se o nome contém apenas letras (sem números)
# Devolve: { "ok": true, "mensagem": "Olá, Maria!..." }
# ============================================================
post '/ex1' do
  dados = JSON.parse(request.body.read)
  nome  = dados['nome'].to_s.strip

  # Verifica se o nome é válido: não pode estar vazio nem conter dígitos
  if nome.empty? || nome.match?(/\d/)
    return { ok: false, erro: 'Nome inválido! Por favor insira apenas letras, sem números.' }.to_json
  end

  { ok: true, mensagem: "Olá, #{nome}! Seja bem-vindo(a)!" }.to_json
end


# ============================================================
# EXERCÍCIO 2 — Calculadora básica
# Recebe: { "a": 10, "b": 3 }
# Valida se ambos são inteiros
# Devolve os 4 resultados: soma, subtração, multiplicação, divisão
# ============================================================
post '/ex2' do
  dados = JSON.parse(request.body.read)

  # Verifica se os valores recebidos são inteiros válidos
  a_raw = dados['a'].to_s
  b_raw = dados['b'].to_s

  unless a_raw.match?(/\A-?\d+\z/) && b_raw.match?(/\A-?\d+\z/)
    return { ok: false, erro: 'Por favor insira apenas números inteiros (sem vírgula ou ponto).' }.to_json
  end

  a = a_raw.to_i
  b = b_raw.to_i

  # Calcula a divisão, tratando o caso de divisão por zero
  divisao = if b == 0
              'Impossível dividir por zero!'
            elsif (a % b).zero?
              (a / b).to_s           # Resultado inteiro (ex: 10 / 2 = 5)
            else
              (a.to_f / b).round(2).to_s  # Resultado decimal arredondado (ex: 10 / 3 = 3.33)
            end

  {
    ok:           true,
    soma:         a + b,
    subtracao:    a - b,
    multiplicacao: a * b,
    divisao:      divisao
  }.to_json
end


# ============================================================
# EXERCÍCIO 3 — Análise de número
# Recebe: { "numero": -7 }
# Verifica: positivo/negativo/zero e par/ímpar
# ============================================================
post '/ex3' do
  dados = JSON.parse(request.body.read)
  raw   = dados['numero'].to_s

  unless raw.match?(/\A-?\d+\z/)
    return { ok: false, erro: 'Por favor insira apenas um número inteiro (sem vírgula ou ponto).' }.to_json
  end

  n = raw.to_i

  # Determina o sinal do número
  sinal = if n > 0 then 'Positivo'
          elsif n < 0 then 'Negativo'
          else 'Zero'
          end

  # Determina paridade usando o operador de módulo (%)
  # O resto da divisão por 2: se 0 é par, se 1 é ímpar
  paridade = n.even? ? 'Par' : 'Ímpar'

  { ok: true, numero: n, sinal: sinal, paridade: paridade }.to_json
end


# ============================================================
# EXERCÍCIO 4 — Tabuada personalizada
# Recebe: { "numero": 5, "limite": 10 }
# Gera a tabuada do número até o limite informado
# ============================================================
post '/ex4' do
  dados = JSON.parse(request.body.read)
  n_raw   = dados['numero'].to_s
  lim_raw = dados['limite'].to_s

  unless n_raw.match?(/\A-?\d+\z/) && lim_raw.match?(/\A\d+\z/)
    return { ok: false, erro: 'Por favor insira apenas números inteiros (sem vírgula ou ponto).' }.to_json
  end

  limite = lim_raw.to_i

  if limite < 1 || limite > 100
    return { ok: false, erro: 'O limite deve ser entre 1 e 100.' }.to_json
  end

  n = n_raw.to_i

  # Gera a tabuada usando o método .map que transforma cada número
  # do intervalo (1..limite) em uma linha da tabuada
  linhas = (1..limite).map { |i| { i: i, resultado: n * i } }

  { ok: true, numero: n, limite: limite, linhas: linhas }.to_json
end


# ============================================================
# EXERCÍCIO 5 — Estatísticas
# Recebe: { "numeros": [3, 7, 1, 9, 5] }
# Calcula: maior, menor, média e mediana
# ============================================================
post '/ex5' do
  dados   = JSON.parse(request.body.read)
  raw_arr = dados['numeros']

  # Verifica se todos os 5 valores são inteiros válidos
  unless raw_arr.is_a?(Array) && raw_arr.length == 5 &&
         raw_arr.all? { |v| v.to_s.match?(/\A-?\d+\z/) }
    return { ok: false, erro: 'Todos os 5 campos são obrigatórios e devem conter apenas números inteiros.' }.to_json
  end

  numeros  = raw_arr.map(&:to_i)
  ordenado = numeros.sort   # Ordena do menor para o maior

  maior  = ordenado.last    # Último elemento = maior
  menor  = ordenado.first   # Primeiro elemento = menor

  # Média: soma de todos dividida pela quantidade
  media  = numeros.sum.to_f / numeros.length

  # Mediana: elemento do meio do array ordenado (5 elementos → índice 2)
  mediana = ordenado[numeros.length / 2]

  {
    ok:      true,
    maior:   maior,
    menor:   menor,
    media:   media % 1 == 0 ? media.to_i : media.round(2),
    mediana: mediana
  }.to_json
end

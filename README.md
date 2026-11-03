# Pipeline de vendas de veículos seminovos

Este projeto pega um CSV de vendas de uma loja de seminovos e o transforma em indicadores, usando Python, SQL e DuckDB. Os dados passam por três camadas: bronze, silver e gold.

## Fonte do dado

- **Dataset:** [Vendas de Veículos Seminovos, no Kaggle](https://www.kaggle.com/datasets/fbarbosaoliveira/vendas-de-veculos-seminovos)
- **Licença:** [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0)
- **Arquivo usado:** `vendas_loja_seminovos.csv`, com 10.950 vendas

Os dados são fictícios e foram criados pelo autor do dataset com a biblioteca Faker. Por isso, os indicadores mostram o funcionamento do pipeline, mas não representam o mercado real.

## O que é uma linha de cada tabela

| Tabela | Uma linha é | Total de linhas |
|---|---|---|
| `bronze.vendas` | Uma linha do CSV, sem alterações | 10.950 |
| `silver.clientes` | O cliente de uma venda | 10.950 |
| `silver.modelos` | Uma combinação de marca e modelo | 59 |
| `silver.vendas` | Uma venda | 10.950 |
| `gold.faturamento_por_marca` | Uma marca | 10 |
| `gold.vendas_por_ano` | Um ano | 9 |
| `gold.vendas_por_estado` | Um estado | 27 |
| `gold.formas_pagamento` | Uma forma de pagamento | 4 |
| `gold.vendas_detalhadas` | Uma combinação de marca, estado, ano e forma de pagamento | 5.012 |

## Camadas

- **Bronze:** carrega o CSV com todas as colunas como texto. Nada é alterado nesta camada.
- **Silver:** corrige os tipos e a marca, e separa o CSV em três tabelas ligadas por chaves. `silver.vendas` se liga a `silver.clientes` por `cliente_id` e a `silver.modelos` por `modelo_id`.
- **Gold:** guarda os indicadores. Cada um é calculado em um arquivo `.sql` próprio e lê apenas da silver.

O dataset tem um único CSV, então as tabelas relacionadas foram criadas na silver. Assim, os indicadores usam `JOIN` sem repetir marca e modelo em todas as vendas.

## Indicadores

| Pergunta | Tabela | Arquivo | Resultado |
|---|---|---|---|
| Quais marcas vendem e faturam mais? | `gold.faturamento_por_marca` | [`sql/gold/faturamento_por_marca.sql`](sql/gold/faturamento_por_marca.sql) | Toyota lidera, com 2.178 vendas e R$ 310.499.881,98 |
| Como as vendas e o faturamento mudam a cada ano? | `gold.vendas_por_ano` | [`sql/gold/vendas_por_ano.sql`](sql/gold/vendas_por_ano.sql) | 2020 tem mais vendas entre os anos completos: 1.419 |
| Em quais estados estão os clientes que mais compram? | `gold.vendas_por_estado` | [`sql/gold/vendas_por_estado.sql`](sql/gold/vendas_por_estado.sql) | MG lidera em vendas (439), e PA, em faturamento (R$ 61.445.645,36) |
| Como os clientes pagam e qual é o valor médio em cada forma? | `gold.formas_pagamento` | [`sql/gold/formas_pagamento.sql`](sql/gold/formas_pagamento.sql) | Consórcio lidera, com 3.786 vendas e média de R$ 141.053,95 |
| Como as vendas se distribuem quando se filtra por marca e por estado? | `gold.vendas_detalhadas` | [`sql/gold/vendas_detalhadas.sql`](sql/gold/vendas_detalhadas.sql) | Alimenta os filtros do dashboard. Exemplo: Toyota em SP tem 83 vendas e R$ 10.834.352,42 |

## Dashboard

**Acesse online:** https://vendas-de-seminovos-brasil.netlify.app

A pasta [`DASHBORD/`](DASHBORD/) tem o dashboard com os indicadores da gold:

- [`DASHBORD/gerar_dashboard.py`](DASHBORD/gerar_dashboard.py) lê `gold.vendas_detalhadas` de `dados/seminovos.duckdb`, em modo só leitura, e confere se, sem filtro, ela bate com as tabelas gold de marca, estado e ano. Se não bater, o script para com erro;
- [`DASHBORD/modelo.html`](DASHBORD/modelo.html) é o layout da página, com o visual e os gráficos;
- [`DASHBORD/site/index.html`](DASHBORD/site/index.html) é a página gerada, que abre direto no navegador, sem servidor e sem internet. A pasta `site` tem só essa página, para ser publicada (por exemplo, arrastando a pasta para https://app.netlify.com/drop).

A página ocupa uma tela só, com tema escuro, e mostra os totais (veículos vendidos, faturamento, ticket médio e marca líder). Cada indicador usa o gráfico que melhor responde à sua pergunta:

| Indicador | Gráfico |
|---|---|
| `gold.faturamento_por_marca` | Ranking de barras horizontais, com posição de cada marca |
| `gold.vendas_por_ano` | Colunas com linha de tendência; 2017 e 2025 aparecem hachurados, porque estão incompletos |
| `gold.formas_pagamento` | Rosca com a participação de cada forma e o ticket médio na legenda |
| `gold.vendas_por_estado` | Mapa do Brasil em blocos, com a cor pela intensidade, e top 5 dos estados |

Ela tem **filtros por marca e por estado**, que podem ser usados juntos. Basta escolher nas listas do topo ou clicar em uma marca do ranking ou em um estado do mapa. Clicar de novo, ou em "Limpar filtros", volta a mostrar todas as vendas. Com um filtro ativo, os totais, a evolução anual e as formas de pagamento mostram só as vendas escolhidas. O ranking e o mapa continuam mostrando todas as opções, com a escolhida em destaque. Por exemplo, ao filtrar a Toyota, o mapa mostra onde a Toyota mais vende.

Além disso, ela é interativa: os botões trocam a métrica (vendas, faturamento ou ticket médio), e o mouse (ou o toque, no celular) sobre qualquer item mostra todos os valores e a participação nas vendas.

Para gerar o dashboard, rode o pipeline antes, porque o script lê o banco criado por ele:

```bash
python src/pipeline.py
python DASHBORD/gerar_dashboard.py
```

Depois, abra `DASHBORD/site/index.html` no navegador.

## Como rodar do zero

É preciso ter Python e Git instalados. Rode os comandos abaixo, nesta ordem:

```bash
git clone https://github.com/ismaelmesquita28-coder/Projeto-final-veiculos-seminovo.git
cd Projeto-final-veiculos-seminovo
python -m pip install -r requirements.txt
python src/pipeline.py
python -m pytest
python DASHBORD/gerar_dashboard.py
```

Rode tudo na pasta principal do projeto, porque o caminho do CSV parte dela. O banco não precisa ser criado à mão: o pipeline cria o arquivo `dados/seminovos.duckdb` e mostra os indicadores no terminal.

O resultado esperado é:

- as contagens da tabela "O que é uma linha de cada tabela";
- `4 passed` nos testes.

## Testes

Os testes ficam em `tests/teste_test.py`. Eles rodam os arquivos `.sql` do projeto com duas vendas inventadas, em um banco temporário na memória, sem abrir `dados/seminovos.duckdb`. Eles conferem se:

- `Volskwagen` é corrigido e o modelo não fica duplicado;
- nenhuma venda se perde na silver;
- a venda com ano anterior ao de fabricação é marcada;
- o faturamento por marca soma as vendas corretamente.

Para confirmar que os testes pegam erros, retirei de propósito a correção da marca em `sql/silver/modelos.sql`. O resultado foi `1 failed, 3 passed`, porque apareceu um modelo a mais com `Volskwagen`. Depois, restaurei o arquivo e os testes voltaram a `4 passed`.

## Decisões sobre o dado

| Situação | Decisão | Motivo |
|---|---|---|
| `Volskwagen` aparece em 1.237 linhas | Corrigir para `Volkswagen` na silver | É erro de digitação, e a bronze não pode ser alterada |
| 14 CPFs se repetem com nomes diferentes | Criar um cliente por venda, sem usar CPF como chave | O CPF não identifica a pessoa com segurança neste dado. Por isso, o projeto não analisa clientes que compraram mais de uma vez |
| 2.400 vendas têm ano anterior ao de fabricação | Manter e marcar em `venda_antes_fabricacao` | O dado é fictício, e não dá para saber qual dos dois valores seria o certo. Essas vendas continuam nos indicadores |
| CPF, e-mail e telefone não são usados | Deixar fora da silver | Nenhum indicador precisa desses dados |
| 1.397 nomes de cidade aparecem em mais de um estado | Não criar indicador por cidade | Não dá para confirmar quais cidades estão corretas |
| 2017 e 2025 têm menos vendas | Manter e avisar | As datas vão de 16/04/2017 a 15/04/2025, então os dois anos estão incompletos |
| A transformação pode perder ou duplicar vendas | Comparar a bronze com a silver no pipeline | Se os totais forem diferentes, o pipeline para com erro |

## Onde a IA errou

Usei IA em todas as etapas e conferi os resultados. Estes foram os principais erros:

1. **Plano com enunciado antigo.** A IA montou o projeto com base em uma versão desatualizada do desafio, uma Mini Loja com menu no terminal, e disse que não podia fazer commit na `main`. Descobri ao reler os requisitos atuais, que pedem um pipeline em três camadas. Por isso, recomecei a partir da `main`.
2. **Tabelas faltando.** Quando ainda estava no plano antigo, o guia da IA mostrou só 2 das 4 tabelas planejadas, e o arquivo ficou incompleto. Descobri ao conferir o arquivo com as tabelas que deveriam existir.
3. **Dashboard sem versão mobile e com design desatualizado.** A primeira versão do dashboard só usava barras simples, em 5 colunas estreitas, com espaço sobrando, e não se adaptava ao celular. Descobri ao abrir a página no navegador e no celular. Pedi um novo layout, com um gráfico adequado a cada indicador, e um ajuste para telas pequenas e para o toque.

Para não depender só da IA, conferi as linhas de cada camada a cada etapa e comparei os resultados com o que era esperado. Também testei a falha de propósito para confirmar que os testes pegam erros.
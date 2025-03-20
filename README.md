# Projeto de Banco de Dados

## Discraft Valley: projeto de banco de dados de um jogo online

Este repositório contém o projeto de banco de dados desenvolvido como parte da disciplina **IF685 - Gestão de Dados e Informação** do curso de Engenharia da Computação. O objetivo deste projeto é modelar e implementar um banco de dados, seguindo um processo dividido em três unidades: modelagem conceitual, modelagem lógica e implementação em SQL.

## Estrutura do Projeto

O projeto está dividido em três etapas principais, cada uma correspondendo a uma unidade da disciplina:

### 1. Modelagem Conceitual
Nesta etapa, desenvolvemos o **Modelo Entidade-Relacionamento (MER)**, identificando:
- **Entidades:** 
- **Relacionamentos:** 
- **Atributos:** 

O diagrama ER foi construído utilizando a ferramenta EERCASE, e está disponível na pasta `ProjConceitual/`.

### 2. Modelagem Lógica Relacional
Com base no MER, elaboramos o **Modelo Lógico** utilizando as regras de normalização de Codd. Nesta fase, definimos:
- **Tabelas:** 
- **Atributos:** 
- **Chaves Primárias e Estrangeiras:** 

O PDF correspondente à modelagem lógica pode ser encontrado na pasta `ProjLogico/`.

### 3. Implementação em SQL
Finalmente, implementamos o banco de dados utilizando **SQL**. Nesta etapa, realizamos:
- **Criação das Tabelas:** Scripts para criar as tabelas no banco de dados.
- **Inserção de Dados:** Scripts para popular as tabelas com dados fictícios.
- **Consultas SQL:** Exemplos de ações que podem ser realizadas.

Os scripts SQL estão disponíveis na pasta `ProjFisico/`.

## Referências
- Clone este repositório:
   ```bash
   git clone https://github.com/mauricioAndrey/Projeto-GDI.git
- Download da ferramenta EERCASE: https://sites.google.com/a/cin.ufpe.br/eercase/home

# Guidelines de Contribuição

## Mensagens de Commit

Utilizamos uma convenção que fornece um conjunto de regras para formular uma estrutura de mensagem de commit consistente da seguinte forma:

```
<type>[optional scope]: <description>
```

O tipo do commit pode ser:

- `feat` – uma nova funcionalidade é introduzida com as mudanças.
- `fix` – ocorreu uma correção de bug.
- `refactor` – código refatorado que não corrige um bug nem adiciona uma funcionalidade.
- `docs` – atualizações na documentação, como o README ou outros arquivos markdown.
- `style` – mudanças que não afetam o significado do código, provavelmente relacionadas à formatação do código, como espaços em branco, pontos e vírgulas ausentes, e assim por diante.

A linha de assunto do tipo de commit deve ser toda em letras minúsculas.

## Criação de Branches

Uma branch do git deve começar com uma categoria. Escolha uma destas: `feature`, `bugfix`, ou `test`.

- `feature` é para adicionar, refatorar ou remover uma funcionalidade.
- `bugfix` é para corrigir um bug.
- `test` é para experimentação.

Após a categoria, deve haver um "/" seguido por uma descrição que resume o propósito desta branch específica. Esta descrição deve ser curta e em `kebab-case`. Para resumir, siga este padrão ao criar branches:

```
git branch <category/description-in-kebab-case>
```

Exemplos:

- Você precisa adicionar, refatorar ou remover uma funcionalidade: `git branch feature/create-new-entity`
- Você precisa corrigir um bug: `git branch bugfix/sql-problem`
- Você precisa experimentar algo: `git branch test/refactor-entity-with-one-relation`

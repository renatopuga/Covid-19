//////////////////////////////////////////////////////////////
///// UNNO TECH - 2020 - unnolab777@gmail.com            /////
///// Servidor principal, sexta feira, 20-03-2020, 00:06 /////
///// Gabriel Riato de Andrade Silva                     /////
///// gabriel.silva@aluno.ufabc.edu.br                   /////
//////////////////////////////////////////////////////////////

//////////////////////////
////Programa principal////
//////////////////////////
function q = ComparaGenomas(arquivo,amostras)
   
// Entradas em txt, arquivos do repositorio Sars-Cov-2 no gitbu hikoyu.    
    // arquivo - fornece os genomas, separados por [>...comentários...] numa única linha
    // amostras - tem todos códigos de amostras correspondentes a cada comentário do arquivo

// Saida: visualização direta em plot conforme passeio dentro da função CoordenadasV4 e matriz de correlações.
 
    Coordenadas = CoordenadasV4(arquivo);
    plotarTodosJuntosV3(Coordenadas);
//    SalvarPlotComparacao(arquivo);
    M = M_corrV3(Coordenadas);
//    PlotaM(M);   //usa surf
//    SalvarPlotMatriz(arquivo);
//    PlotaHistograma(M);
//    SalvarHistograma(arquivo);
    
    q = M; 
  
           
endfunction  //funções comentadas acima ainda estão por elaborar
/////////////////////////////////
////fim do programa principal////
/////////////////////////////////


function q = CoordenadasV4(arquivo)
    //V4: usa PasseioGeonomaV6
    
    //16-03-2020
    // o arquivo do hioyku tem 68 genomas, todos juntos, categorizados pelo nome das amostras
    // daqui sai uma matriz com as coordenadas dos 68 passeios
    
    save arquivo;
    
    genomas = mgetl(arquivo);
    N = length(length(genomas));
    separacoes = grep(genomas,'>');
    dif_separacoes = diff(separacoes);
    imax = find(dif_separacoes==max(dif_separacoes));
    separacoes_maior_genoma = separacoes(imax:(imax+1)); 
    antes = separacoes_maior_genoma(1,1); depois = separacoes_maior_genoma(1,2);
    intervalo = (antes+1):(depois-1);
    maior_genoma = genomas(intervalo);
    n_max = sum(length(maior_genoma))+1;  //nro de coordenadas necessárias
    n_max = n_max*2; //precisa dobrar por causa da simetrização
    n = length(separacoes); //nro de passeios

    Coordenadas = zeros(n_max,n);

    for k = 1:(n-1)
        //eh_impar = modulo(k,2);
        intervalo = (separacoes(k)+1):( separacoes(k+1)-1 )
        genoma =  genomas( intervalo );
        coordenadas = PasseioGenoma2020V6(genoma);
        m = length(coordenadas);
        Coordenadas(1:m,k) = coordenadas; // coordenadas vão sair em vetores coluna
        disp('Matriz Coordenadas ' + string(round(100*k/n))+' por cento concluida');
    end
    
    ultimo_intervalo = (separacoes(n)+1):N;
    genoma = genomas(ultimo_intervalo);
    coordenadas = PasseioGenoma2020V6(genoma);
    m = length(coordenadas);
    Coordenadas(1:m,n) = coordenadas; // coordenadas vão sair em vetores coluna

    
   q = Coordenadas;
    
endfunction


////////////////////


function q = plotarTodosJuntosV3(Coordenadas)
    //V3: finalmente plotando plano cartesiano e não parametrização (como estava antes inadvertidamente)
    
    load arquivo;
    
    amostras = mgetl('sample_list.txt');
    n = length(amostras);
    figure(1);
    plot(real(Coordenadas),imag(Coordenadas));
    set(gca(),'grid',[1 1]);
    ylabel("eixo A-T");    //mapa 2D 
    xlabel("eixo C-G");    //mapa 2D
    n = string(n);
    titulo = strncpy(arquivo,length(arquivo)-4); //retira extensão do nome_arquivo para inserir no título do gráfico
    titulo = "Comparação de " + n + " genomas - arquivo " + titulo ;

    legend(amostras);
    
    
    
    q = 1;
endfunction


/////////////////////


function q = M_corrV3(Coordenadas)
    
    //V3: separando as partes real e imaginária, pois V2 resultou quase tudo NaN
    
    //V2: simplificando a V1 para rodar
    
    
    m = size(Coordenadas); m = m(2);
    
    C = zeros(m,m);
    
    
    for i = 1:m
        for j = (i+1):m 
           C(i,j) = (  correl(real(Coordenadas(:,i)),real(Coordenadas(:,j))) + correl(imag(Coordenadas(:,i)),imag(Coordenadas(:,j)))  )/2;
        end
    end
    
    C = diag(ones(1,m)) + C + C';
    
    q = C;
endfunction



//////////////////


function q=PasseioGenoma2020V6(genoma)
    
    //V6: abolida normalização de passo (adotado passo=1)
    
    //V5: só leitura direta do RNA, sem juntar coordenadas da inversa
    //V4: somente para RNA virus
    //VOLTA icor pois entrada agora vai ser mgetl de um arquivo só, feito antes desse processamento de coordenadas
    
   //BASEADO NA V3_5 DE 2012
    //removido icor da entrada
    
// Programa para visualização do genoma como um todo
// inspirado no Robomind
// VERSÃO 3.5

//Esta função calcula coordenadas para um mapa do arquivo dado.

//Dado de entrada icor indica cor para plotar, é um número inteiro entre 1 e 32.

// O programa moverá dois 'robôs' conforme os seguintes critérios:
    // se a base lida for A andaNorte(1)
    // se a base lida for T andaSul(1)
    // se a base lida for C andaLeste(1)
    // se a base lida for G andaOeste(1)
    // se for um dado espúrio, que o sequenciamento n identificou o 'robô' não se move.

//Podemos esquematizar a sequinte ""rosa dos ventos":
//
//                  A
//                  ^
//                  |
//                  |
//          G ------+------> C
//                  |
//                  |
//                  |
//                  T
 
tic() //para cronometrar o tempo de computação

//save nome_arquivo;

//genoma = mgetl(nome_arquivo ,-1);
genoma = strcat(genoma);

//Obs.: o dado de entrada nome_arquivo deve ser colocado entre aspas, incluindo a extensão do mesmo

n = length(genoma);

x = zeros(1,n);
y = zeros(1,n);
Z = x + %i*y;    
//A trajetória no plano complexo será feita somando a Z os seguintes números:
    // para a base A -->  i
    // para a base T --> -i
    // para a base C -->  1
    // para a base G --> -1
    // para base n reconhecida --> 0

//passo = 1/n;  //normalização para comparar genomas de tamanho diferente
passo = 1;

for k=1:(n-1)
    if part(genoma,k)=='A'
        Z(k+1) = Z(k) + %i*passo  // anda "Norte"
    else
        if part(genoma,k)=='T'
          Z(k+1) = Z(k) - %i*passo; // anda "Sul"
        else
           if part(genoma,k)=='C' then
              Z(k+1) = Z(k) + 1*passo;  // anda "Leste"
           else
               if part(genoma,k)=='G' then
                 Z(k+1) = Z(k) - 1*passo; // anda "Oeste"
               else 
                 Z(k+1) = Z(k);  // não anda (caso genoma(k)=='N')
               end
            end  
         end
     end
end
//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////IMPORTANTE: há 4 formas de leitura do genoma como um caminho de robô.//////////////////////
/// A primeira é a leitura direta do dado, como feito acima. Segue uma descrição das demais...////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////SEGUNDA FORMA///////////////////////////////////////////////////////
//O plano complexo facilita obter o outro lado da deste DNA, simplesmente usando um sinal de menos:///
Zsim = -Z;    //coordenadas correspondentes à leitura desse genoma trocando A<->T e C<->G .///////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////TERCEIRA FORMA//////////////////////////////////////////////////////
//A leitura também poderia ser feita a partir da extremidade oposta. Nesse caso, basta virar o ///////
//vetor do avesso: "os últimos serão os primeiros e os primeiros serão os últimos". //////////////////
//Esse novo vetor se chamará Zinv e será obtido por um 'for'./////////////////////////////////////////
Zinv = Z;   //(valor de inicialização antes de fazer o 'for')//////////////////////////////////////
for k=1:n             /////////////////////////////////////////////////////////////////////////////
   Zinv(k)=Z(n-k+1); //////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
end                   /////////////////////////////////////////////////////////////////////////////
//Obs.: para desenhar um mapa 2D esta e a próxima forma não são relevantes, uma vez que os mesmos //// 
//pontos são percorridos de trás para frente./////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////QUARTA FORMA////////////////////////////////////////////////////////
//O simétrico da leitura ao avesso (Zsi), que é igual à leitura inversa do simétrico(Zis), pode ser //
//facilmente obtido com um sinal de menos:      //////////////////////////////////////////////////////
Zis = -Zinv;    //////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//CONCLUSÃO: nessa representação, cada genoma será desenhado por 4 robôs, que realizarão caminhos ////
//simétricos e inversos, conforme descrito pelos quatro vetores complexos Z's acima calculados.

//t_leitura_e_coordenadas = toc(); // tempo para ler arquivo e gerar coordenadas
//printf("\ntempo gasto para ler arquivo e gerar coordenadas:");
//disp(t_leitura_e_coordenadas);
//printf("segundos\n");


//////PROGRAMA PRINCIPAL INCLUIRÁ MAPA 2D E 3D/////////////////////
///////////////////////////////////////////////////////////////////
////////PARA GERAR MAPA 2D/////////////////////////////////////////
//entradas da função comet:////////////////////////////////////////
///////////////////////////////////////////////////////////////////
//  figure(1);                                                   //
//  X = real( [Z' Zsim'] );                                      //
//  Y = imag( [Z' Zsim'] );                                      //
///////////////////////////////////////////////////////////////////
//icor = icor*ones(1,2);  //caso 2D
//comet(X,Y,"colors",icor);    // geraria mapa 2D deste genoma
//set(gca(),'grid',[1 1]);
//ylabel("eixo A-T");    //mapa 2D 
//xlabel("eixo C-G");    //mapa 2D
// n = string(n);
// titulo = strncpy(nome_arquivo,length(nome_arquivo)-4); //retira extensão do nome_arquivo para inserir no título do gráfico
// titulo = "Passeio pelo genoma " + titulo + " - " + n + " pares de bases" ;
// title(titulo);


////////PARA GERAR MAPA 3D/////////////////////////////////////////
//entradas da função comet3d://////////////////////////////////////
///////////////////////////////////////////////////////////////////
//  figure(2);                                                   //
//X = real( [Z' Zsim' Zinv' Zis'] );  //forma adequada para comet3d//
//Y = imag( [Z' Zsim' Zinv' Zis'] );  //forma adequada para comet3d//
//t = (1/n):(1/n):1;                         //forma adequada para comet3d//
//Z = [t' t' t' t'];    //forma adequada para comet3d/////////////
///////////////////////////////////////////////////////////////////
//icor = icor*ones(1,4);  //caso 3D
//comet3d(X,Y,Z,"colors",icor);    // geraria mapa 3D deste genoma
//set(gca(),'grid',[1 1 1]);
//ylabel("eixo A-T");    //mapa 3D 
//xlabel("eixo C-G");    //mapa 3D
//zlabel("t");    //mapa 3D
// titulo = strncpy(nome_arquivo,length(nome_arquivo)-4); //retira extensão do nome_
 //arquivo para inserir no título do gráfico
 
 //titulo = "Passeio pelo genoma " + titulo + " - " + n + " pares de bases" ;
//titulo = strcat("Passeio pelo genoma " , titulo , "r");
//titulo = strcat(titulo," - " ,"r")
//titulo = strcat(titulo , n ,"r");
//titulo = strcat(titulo, " pares de bases","r") ;
// title(titulo);
//title('Comparação dos genomas');

beep;  // avisa quando acabar plot com um bip

t_total_passeio = toc();
printf("\ntempo total deste passeio (com plot):");
disp(t_total_passeio);
printf("segundos\n");

//Saida = [Z' Zsim' Zinv' Zis'];   //Zsim e Zis não tem muito sentido se é um RNA virus... (não existe o outro lado da fita, como no DNA)
Saida = [Z' Zinv'];

//Saida = simetrizaSaida(Z,Zsim,Zinv,Zis); Saida = Saida';      //concatenação simples se saiu melhor do que essa média geométrica, não altera correlação

Saida = matrix(Saida,length(Saida),1);

q = Saida; //função retorna as coordenadas para o mapa como vetor coluna, para serem usadas pelo programa principal (passeioSgenomaS).


endfunction

# Note per il docente

Lo script è stato trasformato da una sequenza di funzioni ad alto livello in un percorso guidato. Le funzioni nascondevano oggetti intermedi e permettevano di terminare l'esercitazione con pochi click.

Modifiche sostanziali:

- corretta la precedenza logica nel filtro di mitocondri e cloroplasti;
- campioni di controllo e taxa filtrati rimangono coerenti con la matrice usata a valle;
- eliminata la reiniezione della matrice CSS in un oggetto con dimensioni non corrispondenti;
- richness e Shannon sono calcolati sui conteggi filtrati;
- Bray–Curtis è calcolata su abbondanze relative esplicitamente controllate;
- aggiunta PERMANOVA con controllo delle dispersioni multivariate;
- RDA su trasformazione Hellinger con longitudine come predittore; la richness, derivata dalla matrice di comunità, non viene usata come variabile esplicativa.

Il dataset ha 17 campioni, inclusi un controllo negativo e uno positivo. Il negativo ha una library size molto piccola; è utile farlo individuare agli studenti prima di escludere i controlli dall'analisi ecologica.


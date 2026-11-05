# Fichas de artículos científicos

## Estado del arte – Práctica 1: Modelo Entidad-Relación

---

## Artículo 1. Effectively Learning Spatial Indices

### Cita en formato APA 7

Qi, J., Liu, G., Jensen, C. S., & Kulik, L. (2020). Effectively learning spatial indices. *Proceedings of the VLDB Endowment, 13*(12), 2341–2354. https://doi.org/10.14778/3407790.3407829

### DOI

https://doi.org/10.14778/3407790.3407829

### Problema que aborda

El artículo aborda el problema de cómo realizar búsquedas de manera más rápida en bases de datos que contienen grandes cantidades de datos espaciales, como ubicaciones o coordenadas. Los autores señalan que los índices tradicionales pueden requerir recorrer muchos nodos durante una consulta, lo que puede disminuir el rendimiento cuando se manejan grandes volúmenes de información.

### Método o propuesta de los autores

Los autores proponen utilizar aprendizaje automático para crear índices espaciales, en lugar de depender únicamente de estructuras tradicionales como los R-trees. Para lograrlo, utilizan un sistema basado en rank space y una estrategia de partición recursiva, donde una red neuronal aprende a identificar en qué parte de la estructura se encuentra cada dato.

También desarrollan métodos para realizar consultas de puntos, ventanas y vecinos más cercanos (kNN).

### Resultado principal

Los experimentos realizados con datos reales y sintéticos de más de 100 millones de puntos mostraron que el índice propuesto puede procesar consultas considerablemente más rápido que los R-trees y que otro índice basado en aprendizaje automático. Algunas consultas fueron más de diez veces más rápidas que utilizando estas alternativas.

### Relación con la Unidad Temática I

Se relaciona principalmente con el tema **1.3.3 Módulos componentes de un SGBD**, debido a que los índices forman parte de los mecanismos utilizados por un sistema de bases de datos para acceder a la información de manera eficiente.

También se relaciona con **1.1.1 Fundamentos de Bases de Datos**, porque aborda la organización de la información y la búsqueda eficiente cuando se realizan consultas.

### ¿Qué aporta al proyecto?

Este artículo permite comprender que una base de datos no solamente sirve para almacenar información, sino que también es importante considerar cómo se consulta y procesa esa información de manera eficiente.

Para el proyecto EcoData puede ser útil al manejar una gran cantidad de registros relacionados con productos, consumo de agua, emisiones, productos reciclables, impacto por categoría, impacto por país y materiales utilizados.

Además, relaciona el proyecto con la Inteligencia Artificial, ya que muestra cómo el aprendizaje automático puede utilizarse para mejorar el funcionamiento de una base de datos.

---
## Artículo 2. Modeling Shifting Workloads for Learned Database Systems

### Cita en formato APA 7

Wu, P., & Ives, Z. G. (2024). Modeling shifting workloads for learned database systems. *Proceedings of the ACM on Management of Data, 2*(1), Article 38, 1–27. https://doi.org/10.1145/3639293

### DOI

https://doi.org/10.1145/3639293

### Problema que aborda

El artículo aborda el problema que presentan algunos sistemas de bases de datos que utilizan aprendizaje automático cuando cambia la forma en que se realizan las consultas. Un modelo puede funcionar correctamente con los datos y consultas utilizados durante su entrenamiento, pero perder precisión cuando recibe información diferente o cuando cambia la carga de trabajo.

Esto es importante porque las consultas que realizan los usuarios pueden cambiar con el tiempo. Por ello, el sistema necesita una forma de adaptarse a estos cambios sin tener que comenzar nuevamente todo el proceso de aprendizaje.

### Método o propuesta de los autores

Los autores proponen utilizar un replay buffer, que consiste en conservar una selección de ejemplos representativos de las cargas de trabajo que el sistema ha observado.

Para administrar estos ejemplos utilizan algoritmos en línea, de manera que el contenido del replay buffer pueda actualizarse conforme aparecen nuevas consultas.

### Resultado principal

Los experimentos muestran que el manejo del replay buffer permite mantener un conjunto de ejemplos pequeño, pero representativo de diferentes cargas de trabajo.

El mecanismo ayuda a que los sistemas de bases de datos que utilizan aprendizaje automático se adapten a los cambios en las consultas y puedan realizar predicciones relacionadas con la cardinalidad y el costo de las consultas.

### Relación con la Unidad Temática I

Se relaciona principalmente con el procesamiento y la optimización de consultas.

En una base de datos, el optimizador necesita realizar estimaciones para decidir cuál es una forma adecuada de ejecutar una consulta. El artículo muestra cómo estas estimaciones pueden apoyarse en modelos de aprendizaje automático.

### ¿Qué aporta al proyecto?

Este artículo aporta la idea de que una base de datos puede utilizar técnicas de aprendizaje automático no solamente para trabajar con la información almacenada, sino también para mejorar su propio funcionamiento.

En EcoData podría ser útil considerar mecanismos que permitan mejorar el rendimiento de las consultas a partir de la información obtenida durante el uso del sistema.

---
## Artículo 3. Stratus ML: A Layered Cloud Modeling Framework

### Cita en formato APA 7

Hamdaqa, M., & Tahvildari, L. (2015). Stratus ML: A layered cloud modeling framework. In *2015 IEEE International Conference on Cloud Engineering (IC2E)* (pp. 96–105). IEEE. https://doi.org/10.1109/IC2E.2015.42

### DOI

https://doi.org/10.1109/IC2E.2015.42

### Problema que aborda

Los autores abordan la dificultad de diseñar aplicaciones para la nube debido a la falta de un marco de modelado integrado que considere las necesidades de los diferentes participantes y las características específicas de los servicios de nube.

### Método o propuesta de los autores

Los autores proponen StratusML, un marco de modelado integrado y agnóstico de la tecnología para aplicaciones en la nube.

El framework permite definir servicios, configurar aplicaciones, especificar reglas de adaptación durante la ejecución y estimar costos bajo diferentes plataformas y configuraciones de nube.

### Resultado principal

StratusML proporciona una forma integrada de modelar aplicaciones en la nube y facilita la colaboración entre diferentes participantes, como proveedores, desarrolladores, administradores y responsables de decisiones financieras.

### Relación con la Unidad Temática I

Se relaciona con los conceptos de arquitectura, sistemas y tecnologías utilizadas para implementar servicios tecnológicos. También permite comprender la importancia de utilizar una estructura organizada para diseñar y administrar sistemas.

### ¿Qué aporta al proyecto?

El artículo permite comprender la importancia de utilizar arquitecturas y modelos organizados para desarrollar sistemas tecnológicos. En el proyecto permite relacionar el diseño de la base de datos y los servicios que utilizan la información con una arquitectura más amplia, considerando aspectos como configuración, adaptación y funcionamiento del sistema.

---

## Conclusión

Los tres artículos muestran diferentes formas en las que las tecnologías actuales pueden mejorar los sistemas de información. El primer artículo muestra el uso del aprendizaje automático para mejorar los índices de bases de datos; el segundo aborda la adaptación de sistemas de bases de datos ante cambios en las cargas de trabajo; y el tercero presenta un marco de modelado para aplicaciones en la nube.

En conjunto, los artículos permiten relacionar los fundamentos de las bases de datos con aplicaciones actuales de Inteligencia Artificial, optimización y arquitectura de sistemas.

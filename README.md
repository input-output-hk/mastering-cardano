# **Mastering Cardano: Una guía de código abierto al ecosistema de Cardano**

> _Esta traducción al español se encuentra actualmente en desarrollo._

![Mastering Cardano Cover](images/cover.png)

**Mastering Cardano está disponible en formato electrónico (en inglés) en [Book.io](https://book.io/). Para adquirirlo, [haz click en este enlace](https://book.io/book/mastering-cardano/).**

Bienvenido a _Mastering Cardano:, un libro integral y de código abierto dedicado a explorar a fondo la blockchain de Cardano. Esta obra es un esfuerzo colaborativo escrito por expertos y miembros de la comunidad pensada para que cualquier persona interesada en comprender, desarrollar o participar en el ecosistema de Cardano pueda dar sus primeros pasos o ahondar en aspectos específicos de Cardano.

_Mastering Cardano_ es un documento vivo, diseñado para evolucionar junto con la plataforma Cardano. Lo invitamos a usted, lector, a acompañarnos en este camino de aprendizaje y colaboración.

## Licencia

Copyright © 2025 por IOG Singapore Pte. Ltd.

Esta obra está licenciada bajo una Licencia Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

Para consultar una copia de esta licencia, visite [Deed - Attribution-NonCommercial-ShareAlike 4.0 International - Creative Commons](https://creativecommons.org/licenses/by-nc-sa/4.0/).

## Acerca del libro

_Mastering Cardano_ ofrece una exploración exhaustiva de la blockchain de Cardano, desde sus principios fundamentales hasta las complejidades del desarrollo de contratos inteligentes y la gobernanza descentralizada. El libro está estructurado para atender a una amplia audiencia, incluidos desarrolladores, operadores de stake pools, estudiantes y entusiastas.

### Tabla de contenidos

1. _Introducción_ — una introducción a la tecnología blockchain, los contratos inteligentes y los conceptos fundamentales de Cardano.  
2. _Criptografía_ — una visión general de los principios criptográficos que aseguran la red Cardano.  
3. _Conozca Cardano_ — un análisis profundo de la historia, principios centrales y ecosistema de Cardano.  
4. _Cómo funciona Cardano_ — explicaciones detalladas del nodo de Cardano, el modelo EUTXO, el consenso Ouroboros y los activos nativos.  
5. _Gobernanza de Cardano_ — una exploración del modelo de gobernanza descentralizada de Cardano, incluyendo los CIPs, Project Catalyst y la Era de Voltaire.  
6. _Carteras digitales de Cardano_ — una guía para usar y comprender las carteras digitales dentro del ecosistema Cardano.  
7. _Stake pools y operación de stake pools_ — una guía integral para operadores de stake pools, tanto aspirantes como actuales.  
8. _Escritura de contratos inteligentes_ — una guía práctica para desarrollar contratos inteligentes en Cardano utilizando Plutus y Marlowe.  
9. _Aplicaciones descentralizadas (DApps)_ — una introducción a la construcción e interacción con DApps en Cardano.  
10. _Mirando hacia el futuro_ — una visión del porvenir de Cardano, incluyendo soluciones de escalabilidad como Hydra y Mithril.  

## Cómo usar este libro

_Mastering Cardano_ está diseñado para ser flexible. Puede leerse de principio a fin o seguir uno de los caminos de lectura sugeridos de acuerdo con sus intereses:

* _Ruta de fundamentos de Cardano_ — para principiantes que desean una comprensión sólida de blockchain y Cardano.  
* _Ruta para desarrolladores de contratos inteligentes_ — para desarrolladores que buscan construir contratos inteligentes y DApps en Cardano.  
* _Ruta para usuarios de Cardano_ — para usuarios no técnicos que desean aprender a usar e interactuar con el ecosistema Cardano.  
* _Ruta para operadores de stake pool_ — para quienes estén interesados en administrar y mantener un stake pool.  
* _Ruta de gobernanza y futuro de Cardano_ — para lectores interesados en la visión a largo plazo y en la gobernanza de Cardano.  

## Construcción del libro

Este libro está escrito en AsciiDoc. Para generar sus propias versiones en PDF y EPUB a partir del código fuente, siga estos pasos.  

### Prerrequisitos

* _Ruby y Bundler_ — el proceso de construcción depende de Ruby y Bundler. Asegúrese de tener instalada una versión reciente de Ruby.  
* _Graphviz_ — requerido para renderizar diagramas en el libro.  

### Instrucciones de construcción

1. Clone el repositorio, como se indica:  

   ```bash
   git clone https://github.com/input-output-hk/mastering-cardano.git
   cd mastering-cardano
   ```  

2. Instale Ruby y las herramientas de compilación:  
   En sistemas basados en Debian (como Ubuntu), puede instalar Ruby y las herramientas de compilación con:  

   ```bash
   sudo apt-get install -y ruby-full build-essential
   ```  

3. Instale Bundler:  
   Instale Bundler para el usuario actual:  

   ```bash
   gem install bundler --user-install
   ```  

4. Configure las variables de entorno:  
   Configure las variables de entorno necesarias para usar las gemas instaladas por el usuario. Primero, verifique su versión de Ruby:  

   ```bash
   ruby --version
   ```  

   Luego exporte la ruta usando su versión de Ruby (reemplace `X.Y.0` con su versión, por ejemplo, `3.1.0`):  

   ```bash
   export PATH="$HOME/.local/share/gem/ruby/X.Y.0/bin:$PATH"
   export BUNDLE_PATH="$HOME/.local/share/gem"
   ```  

5. Instale las dependencias, como sigue:  
   Este proyecto utiliza Bundler para gestionar las gemas de Ruby. Instale las gemas requeridas con:  

   ```bash
   bundle install
   ```  

6. Instale Graphviz:  
   En sistemas basados en Debian (como Ubuntu), puede instalar Graphviz con:  

   ```bash
   sudo apt-get update && sudo apt-get install -y graphviz
   ```  

7. Compile el libro:  
   Puede compilar tanto la versión en PDF como en EPUB utilizando el Makefile: `make`  

   De forma alternativa, puede compilar cada formato individualmente:  
   * Para generar el PDF: `make pdf`  
   * Para generar el EPUB: `make epub`  

Los archivos generados se colocarán en el directorio `dist/`.  

## Contribuciones

_Mastering Cardano_ es un proyecto impulsado por la comunidad, y damos la bienvenida a todo tipo de contribuciones. Ya sea corrigiendo un error tipográfico, aclarando un concepto o agregando nuevo contenido, su participación es valiosa.  

Para contribuir, bifurque el repositorio y envíe una pull request con sus cambios propuestos. Para cambios más significativos, recomendamos abrir primero un issue para discutir sus ideas con la comunidad.  

## Acerca de los autores

_Mastering Cardano_ está escrito por el _Dr. Lars Brünjes_, Director de Educación en Input | Output, y el _Prof. Joshua Ellul_, Director del Centre for DLT en la Universidad de Malta, con contribuciones de numerosos expertos y miembros de la comunidad. Este libro es un testimonio del espíritu colaborativo y de código abierto del ecosistema Cardano.  

Esperamos que disfrute la lectura de _Mastering Cardano_ y lo considere un recurso valioso en su camino hacia el mundo de blockchain.

¡Disfrute la lectura!

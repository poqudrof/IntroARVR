# IntroARVR
Travaux pratiques d'introduction à la Réalité Augmentée et la Réalité Virtuelle. 



## Objectifs du TP

Comprendre la problématique de la Réalité Augmentée, par la détection et modèlisation du monde physique. 
Créer une application d'interacition et rendu à échelle métrique et non virtuelle (pixels). 

### Partie 1: Détection d'objet

* Détection d'un objet coloré avec une caméra. 
* [Pause mathématique]: Estimation de la distance de cet objet en millimètre.
* Calcul de la distance de cet objet en millimètres.

### Partie 2: Affichage à l'échelle

* Affichage à échelle en millimètre sur un écran PC. 
* Rendu autour d'objets physiques. 
* Sélection d'objets physiques avec le détecteur de la partie 1.

### Partie 3: Fenêtre de réalité virtuelle (Bonus)

* Rendu 3D à l'intérieur de l'écran.
* Rendu Stéréoscopique et effet holographique.



# Partie 0 Mise en route 

Téléchargez et extrayez l'archive processing:

* Processing [Téléchargement windows](http://download.processing.org/processing-3.5.3-windows64.zip), [mirroir1](http://vps601605.ovh.net/rails/processing-3.5.3-windows64.zip), [mirroir2](http://dist.rea.lity.tech/libs/processing-3.5.3-windows64.zip).
* Gardez un onglet ouvert vers la [documentation](https://processing.org/reference/).

Au premier lancement, un dossier `Processing` est crée dans `Mes Documents`. 
Vous devez installer les bibliothèques `Video` et `ControlP5` depuis le la barre de menu de Processing.

> Select "Add Library..." from the "Import Library..." submenu within the Sketch menu.

* Video: https://github.com/processing/processing-video/releases/download/2/video-2.zip
* ControlP5: https://github.com/sojamo/controlp5/releases/download/v2.2.5/controlP5-2.2.5.zip

* Relancez Processing, et testez la bibliothèque Vidéo. 



> File -> Examples... puis   Libraries / Video / Capture / GettingStartedCapture 


# Partie 1 Détection d'objets

## Sélection de couleur

### Cours - Introduction à la couleur

> Suivez sur la page de Processing: https://processing.org/tutorials/color/

### Lancement de l'activité. 

Étapes: 

1. Téléchargez l'archive de ce dépôt: https://github.com/poqudrof/IntroARVR/archive/master.zip
2. Extraire dans votre dossier `Processing` nouvellement crée. 
3. Lancez le sketch `ColorTracker`. 
4. Lisez le code attentivement. 

### Code existant

Identifiez ces éléments dans le code:

* Le code existant permet déjà de capturer un flux vidéo en temps réel. 
* Vous avez un exemple de menu (slider) avec `ControlP5` qui rempli la valeur `error`.  
* Vous pouvez sélectionner une couleur à la souris. 
* Il y a une boucle d'analyse d'image qui itère à travers tout les pixels du flux vidéo. 
* Une image (`colorTrackingImage`) est initialisée puis rendue sous l'image du flux vidéo. 

### Distance de couleur RGB

1. Sélectionnez une couleur dans l'image, et affichez les pixels ayant la même couleur exactement. 
2. Affichez les pixels ayant une couleur proche.
3. Musurez la taille en pixels de l'objet détecté. 

### Distance de couleur HSB

1. Utilisez l'espace de couleur HSB au lieu de RGB pour trouver les couleurs ayant une couleur proche. 
2. Améliorez la qualité de vos détections en appliquant des [filtres](https://processing.org/reference/filter_.html) à vos images. 


## Pause mathématique: Passage à échelle physique

### Poser le problème
Problème: On viens de mesurer `AB` en pixels, et on peut mesurer `CD` en millimètres. On veut maintenant connaître la distance réelle de l'objet en millièmetres ainsi que sa position en millimètres. 

![Schema](https://github.com/poqudrof/IntroARVR/raw/master/image.png)

Pour simplifier, on considère que  `dx = OC = OD`. 

Trouvez un moyen mathématique de calculer `OC`. Pour l'implémentation on partira sur une distance focale `float fx = 800;`. Proposez une méthode simple pour mesurer la vraie valeur de votre distance focale.

### Implémenter la solution 

Implémentez la solution dans votre programme. 


### Envoi sur le réseau

Le résultat du tracking donne une position 3D (X, Y, Z). Envoyez la sur le réseau. Voilà comment transformer votre programme actuel en serveur. 

``` java 
import processing.net.*; 
// ... 
Server server;
void setup(){
  //... 
 try{
   server = new Server(this, 12345); // Start a simple server on a port
 }catch(Exception e){
	println("Serveur issue... " + e);
}

void sendToServer(PVector pos){
  try{  
    String message = pos.x + " " + pos.y + " " + pos.z + "\n"; 
    server.write(message);
  }catch(Exception e){
   println("Serveur issue " + e);
  }
}
```

# Partie 2 Affichage à l'échelle 

Résultat intermédiaire: https://gist.github.com/poqudrof/414ad6b7fa78dfcf353f659b2e956a70

## Rendu en millimètres

1. Partez du sketch `RenderScale` pour implémenter un rendu à échelle millimètrique au lieu de pixels. 
2. Créez un affichage à taille réel avec des élements (cercles ou rectangles).
3. Ajustez les positions de l'affichage par rapport à la caméra pour que les positions données par la caméra soient cohérentes avec celles rendues (calibration). 
3. Sélectionnez les éléments dessinée en (2) avec l'objet tracké dans la partie 1. 

# Partie 3 Fenêtre de Réalité Virtuelle

## Rendu 3D dans l'écran 

Votre système de tracking peut fournir des positions pour un rendu type «fenêtre de réalité virtuelle». Ceci est inspiré de la video de Johnny Chung Lee: https://youtu.be/Jd3-eiid-Uw?t=125 . 

* Pressez `h` pour utiliser votre tracking comme position de la tête. 
* Ajustez les paramètres du sketch pour la taille de votre écran. 



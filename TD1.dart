// fichier: produit.dart
class Produit {
  String nom;
  double prix;
  int stock;
  String categorie;

  Produit(this.nom, this.prix, this.stock, this.categorie);

  void afficherDetails() {
    print("Produit: $nom | Prix: $prix DH | Stock: $stock | Catégorie: $categorie");
  }
}

// fichier: exceptions.dart
class StockInsuffisantException implements Exception {
  String cause;
  StockInsuffisantException(this.cause);
}

class CommandeVideException implements Exception {
  String cause;
  CommandeVideException(this.cause);
}

// fichier: commande.dart
import 'produit.dart';
import 'exceptions.dart';

class Commande {
  int id;
  Map<Produit, int> produits = {};
  double total = 0;

  Commande(this.id);

  void ajouterProduit(Produit produit, int quantite) {
    if (produit.stock < quantite) {
      throw StockInsuffisantException("Stock insuffisant pour ${produit.nom}");
    }
    produits.update(produit, (q) => q + quantite, ifAbsent: () => quantite);
    produit.stock -= quantite;
    calculerTotal();
  }

  void calculerTotal() {
    total = produits.entries
        .map((entry) => entry.key.prix * entry.value)
        .fold(0, (a, b) => a + b);
  }

  void afficherCommande() {
    if (produits.isEmpty) {
      throw CommandeVideException("La commande est vide.");
    }
    print("Commande n°$id :");
    produits.forEach((produit, quantite) {
      print("- ${produit.nom} x$quantite => ${produit.prix * quantite} DH");
    });
    print("Total: $total DH");
  }
}

// fichier: utils.dart
import 'produit.dart';
import 'commande.dart';

List<Produit> listeProduits = [
  Produit("iPhone", 12000, 5, "Phone"),
  Produit("Samsung Galaxy", 8500, 3, "Phone"),
  Produit("Clavier", 400, 10, "Accessoire"),
  Produit("Écran", 1500, 4, "Périphérique"),
  Produit("Chargeur", 120, 8, "Accessoire"),
];

Produit? rechercherProduitParNom(String nom) {
  return listeProduits.firstWhere(
    (produit) => produit.nom.toLowerCase() == nom.toLowerCase(),
    orElse: () => throw Exception("Produit non trouvé"),
  );
}

void afficherProduitsCommandes(Map<Produit, int> produits) {
  var formatListe = produits.entries.map((e) => "${e.key.nom} x${e.value}");
  print("Produits commandés : ${formatListe.join(', ')}");
}

void filtrerProduitsChers() {
  var chers = listeProduits.where((p) => p.prix > 50);
  print("Produits > 50 DH :");
  chers.forEach((p) => p.afficherDetails());
}

void produitLePlusCher() {
  var max = listeProduits.reduce((a, b) => a.prix > b.prix ? a : b);
  print("Produit le plus cher : ${max.nom} à ${max.prix} DH");
}

void appliquerRemiseSurPhones() {
  listeProduits
      .where((p) => p.categorie == "Phone")
      .forEach((p) => p.prix *= 0.9);
  print("Remise appliquée sur les téléphones.");
}

void transformerPrixProduits(double Function(double) transformation) {
  listeProduits.forEach((p) => p.prix = transformation(p.prix));
}

void afficherTousLesProduitsCommandes(Commande commande) {
  commande.produits.forEach((produit, quantite) {
    print("${produit.nom} - Quantité: $quantite - Prix unitaire: ${produit.prix}");
  });
}

// fichier: main.dart
import 'commande.dart';
import 'utils.dart';
import 'exceptions.dart';

void main() {
  try {
    var commande1 = Commande(1);

    commande1.ajouterProduit(rechercherProduitParNom("iPhone")!, 1);
    commande1.ajouterProduit(rechercherProduitParNom("Clavier")!, 2);

    commande1.afficherCommande();

    afficherProduitsCommandes(commande1.produits);
    filtrerProduitsChers();
    produitLePlusCher();

    appliquerRemiseSurPhones();
    transformerPrixProduits((prix) => prix * 1.2); // TVA
    afficherTousLesProduitsCommandes(commande1);
  } catch (e) {
    print("Erreur : $e");
  }
}

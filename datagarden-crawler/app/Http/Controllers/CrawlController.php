<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;

class CrawlController extends Controller
{
    public function startCrawl(Request $request)
    {
        // Crawl logic
        // dd($request->request->all());
        $baseUrl = $this->getBaseUrl($request->request->get("url"));
        $urls = $this->getAllLinks($request->request->get("url"));

        $ranks = [];

        foreach ($urls as $url) {
            if(!str_contains($url, $request->request->get("url"))) {
                continue;
            }
            $ranks[$url] = -1;
            // $ranks[$url] = $this->getGoogleSearchRank($url, $request->request->get("keyword"));
        }
        
        // dd($ranks);
        // Redirect
        return redirect()->route('reports');
    }

    private function getAllLinks(string $siteUrl) {

        $baseUrl = $this->getBaseUrl($siteUrl);
        // Create DOMDocument object 
        $dom = new \DOMDocument();

        // Load target content
        $html = file_get_contents($siteUrl);
        libxml_use_internal_errors(true);

        $dom->loadHTML($html);

        // Récupérer tous les éléments "a" (liens) de la page
        $links = $dom->getElementsByTagName('a');

        // Tableau pour stocker les URLs des liens
        $urls = [];

        // Parcourir tous les liens et extraire leurs URLs
        foreach ($links as $link) {
            $url = $link->getAttribute('href');

            if($siteUrl == $url || $baseUrl == $url) {
                continue;
            }

            // Ignorer les liens vides ou ceux qui ne commencent pas par "http" ou "https"
            if (!empty($url) && (strpos($url, 'http') === 0 || strpos($url, 'https') === 0) && str_contains($url, $baseUrl)) {
                $urls[] = $url;
            }
        }

        return $urls;
    }

    function getGoogleSearchRank($siteUrl, $query) {
        // Clé API et ID du moteur de recherche personnalisé Google
        $apiKey = 'VOTRE_CLE_API';
        $cx = 'VOTRE_ID_MOTEUR_DE_RECHERCHE_PERSONNALISE';
    
        // URL de l'API Google Custom Search
        $url = 'https://www.googleapis.com/customsearch/v1?key=' . $apiKey . '&cx=' . $cx . '&q=' . urlencode($query);
    
        // Effectuer la demande HTTP
        $response = file_get_contents($url);
    
        // Analyser la réponse JSON
        $data = json_decode($response, true);
    
        // Parcourir les résultats pour trouver le classement du site
        $rank = null;
        foreach ($data['items'] as $index => $item) {
            if (strpos($item['link'], $siteUrl) !== false) {
                // Le site a été trouvé dans les résultats de recherche Google
                // Enregistrer le classement et sortir de la boucle
                $rank = $index + 1; // Les classements commencent à partir de 1
                break;
            }
        }
    
        return $rank;
    }

    function getBaseUrl($url) {
        // Analyser l'URL
        $parsedUrl = parse_url($url);
    
        // Vérifier si le schéma est défini
        $scheme = isset($parsedUrl['scheme']) ? $parsedUrl['scheme'] . '://' : '';
    
        // Vérifier si le port est défini et différent des ports par défaut
        $port = isset($parsedUrl['port']) && !in_array($parsedUrl['port'], [80, 443]) ? ':' . $parsedUrl['port'] : '';
    
        // Créer la base URL
        $baseUrl = $scheme . $parsedUrl['host'] . $port;
    
        return $baseUrl;
    }
    
}

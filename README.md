# Wdrożenie środowiska rozproszonego w chmurze Azure z użyciem Infrastructure as Code

**Temat projektu:** 11. Wdrożenie infrastruktury chmurowej (Container Apps, PostgreSQL, VNet, Monitoring, IAM) w modelu IaC przy użyciu narzędzia Terraform.

## Cel systemu
Automatyzacja procesu dostarczania, configuration oraz zabezpieczania rozproszonego środowiska chmurowego w Microsoft Azure zintegrowanego z warstwą aplikacyjną i kontrolą wersji. Projekt eliminuje konieczność ręcznego "wyklikiwania" zasobów w portalu, zapewniając pełną powtarzalność, audytowalność za pomocą systemu Git oraz bezpieczeństwo infrastruktury, która w końcowym etapie z powodzeniem hostuje i eksponuje w internecie działającą aplikację kontenerową.

## Główne funkcje i zakres
Wdrożenie kompletnego stosu technologicznego oraz konfiguracja operacyjna realizowane za pomocą procesu ciągłego wdrożenia (Terraform Init/Plan/Apply) oraz narzędzi wspierających:

* **Przygotowanie subskrypcji:** Rejestracja wymaganych dostawców zasobów chmurowych (w szczególności przestrzeni nazw `Microsoft.App`) z poziomu interfejsu wiersza poleceń Azure CLI.
* **Infrastruktura sieciowa:** Stworzenie odizolowanej sieci wirtualnej (VNet) wraz z dedykowaną podsiecią (Subnet) dla bezpiecznej komunikacji usług.
* **Warstwa danych:** Powołanie elastycznego serwera relacyjnej bazy danych (Azure Database for PostgreSQL Flexible Server) w zoptymalizowanym kosztowo profilu wydajnościowym.
* **Środowisko uruchomieniowe i monitoring:** Przygotowanie bezserwerowego środowiska dla kontenerów (Azure Container Apps Environment) zintegrowanego ze scentralizowanym systemem zbierania logów i metryk (Log Analytics Workspace).
* **Wdrożenie kontenerów (Azure Container Apps):** Implementacja i uruchomienie publicznie dostępnej aplikacji kontenerowej opartej o obraz testowy (`hello-world`). Konfiguracja obejmowała przypisanie zasobów obliczeniowych (CPU/RAM) oraz ustawienie reguł routingu sieciowego (Ingress) na porcie 80, aby wyeksponować aplikację w internecie.
* **Próba implementacji użytkowników (IAM):** Zaprojektowanie struktury uprawnień (RBAC) oraz automatycznego tworzenia kont użytkowników (Programista, Audytor) w usłudze Microsoft Entra ID. Z powodu globalnych restrykcji i braku uprawnień na katalogu uczelnianym (błąd 403), implementacja posłużyła jako test rozwiązywania problemów (troubleshooting), a sam kod został profesjonalnie wykomentowany, zachowując logikę na przyszłość.
* **Wersjonowanie i dokumentacja:** Zabezpieczenie kodu źródłowego, odizolowanie plików stanu i sekretów za pomocą mechanizmu `.gitignore` oraz opublikowanie kompletnego repozytorium wraz z dokumentacją w serwisie GitHub.

## Cele projektowe (priorytety)
1. **Opanowanie podejścia Infrastructure as Code (IaC):** Nauka deklaratywnego opisywania zasobów za pomocą języka HCL (HashiCorp Configuration Language), automatyzacji wdrożeń oraz zarządzania plikami stanu chmury (state file).
2. **Architektura Multi-Region (Obejście ograniczeń):** Praktyczne wdrożenie infrastruktury rozproszonej w różnych regionach geograficznych (baza danych w Szwecji, środowisko kontenerowe w Niemczech) w celu ominięcia rygorystycznych limitów i braku alokacji darmowych zasobów narzucanych na subskrypcje edukacyjne (Azure for Students).
3. **Idempotentność środowiska:** Zagwarantowanie, że wielokrotne uruchomienie kodu nie stworzy duplikatów infrastruktury, a jedynie wyrówna stan faktyczny chmury z zadeklarowanym kodem źródłowym.
4. **Zarządzanie ograniczeniami (Troubleshooting) i obsługa błędów:** Praktyczna diagnoza problemów z uprawnieniami podczas próby implementacji użytkowników w środowisku edukacyjnym. Zamiast usuwać kod, zastosowano inżynierską praktykę "commenting out", co dokumentuje architekturę IAM i przygotowuje projekt do łatwej migracji na płatną subskrypcję. Z sukcesem wdrożono za to warstwę kontenerową, udowadniając działanie całego zautomatyzowanego potoku.


##  Technologie
* **Infrastructure as Code:** Terraform (Providerzy: `hashicorp/azurerm`, `hashicorp/azuread`)
* **Konfiguracja i diagnostyka:** Azure CLI
* **Platforma chmurowa:** Microsoft Azure (w tym Microsoft Entra ID)
* **Zasoby chmurowe:** Azure Container Apps, Container Apps Environment, PostgreSQL Flexible Server, Virtual Network, Log Analytics Workspace
* **Repozytorium i wersjonowanie:** Git / GitHub

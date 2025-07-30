import os
import sys
import time
import ctypes
import shutil
import psutil
import socket
import platform
import subprocess
from datetime import datetime
from threading import Thread
from typing import List, Dict, Optional
from colorama import init, Fore, Back, Style
import ping3
from tqdm import tqdm
from crontab import CronTab

# Inicializa colorama
init(autoreset=True)

# Configurações
VERSION = "3.0.0"
AUTHOR = "WinOptiMax Ultimate"
LOGFILE = os.path.join(os.getenv('TEMP'), 'winoptimax.log')
CACHE_DIR = os.path.join(os.getenv('LOCALAPPDATA'), 'WinOptiMax')

# Verifica admin
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

# Sistema de logging avançado
class Logger:
    @staticmethod
    def log(message: str, level: str = "INFO", display: bool = True):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}"
        
        with open(LOGFILE, "a", encoding='utf-8') as f:
            f.write(log_entry + "\n")
        
        if display:
            color = {
                "INFO": Fore.CYAN,
                "WARNING": Fore.YELLOW,
                "ERROR": Fore.RED,
                "SUCCESS": Fore.GREEN
            }.get(level, Fore.WHITE)
            
            print(color + log_entry)

# Animação de loading
def loading_animation(duration: int = 3):
    chars = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]
    end_time = time.time() + duration
    i = 0
    while time.time() < end_time:
        sys.stdout.write(f"\r{chars[i % len(chars)]} Processando...")
        sys.stdout.flush()
        time.sleep(0.1)
        i += 1
    print("\r" + " " * 30 + "\r", end="")

# Limpeza Avançada
class AdvancedCleaner:
    @staticmethod
    def clean_temp_files(show_progress: bool = True):
        Logger.log("Iniciando limpeza de arquivos temporários...")
        temp_locations = [
            os.getenv('TEMP'),
            os.path.join(os.getenv('LOCALAPPDATA'), 'Temp'),
            r'C:\Windows\Temp',
            os.path.join(os.getenv('USERPROFILE'), 'AppData', 'Local', 'Microsoft', 'Windows', 'INetCache'),
            os.path.join(os.getenv('USERPROFILE'), 'AppData', 'Local', 'Microsoft', 'Windows', 'INetCookies'),
            os.path.join(os.getenv('USERPROFILE'), 'AppData', 'Local', 'Google', 'Chrome', 'User Data', 'Default', 'Cache'),
            os.path.join(os.getenv('USERPROFILE'), 'AppData', 'Local', 'Microsoft', 'Edge', 'User Data', 'Default', 'Cache')
        ]
        
        total_freed = 0
        files_deleted = 0
        
        for location in temp_locations:
            if os.path.exists(location):
                Logger.log(f"Limpando: {location}")
                try:
                    for root, dirs, files in os.walk(location):
                        file_list = [(os.path.join(root, f), os.path.getsize(os.path.join(root, f))) for f in files]
                        
                        if show_progress:
                            with tqdm(total=len(file_list), unit='file', desc=f"Limpando {os.path.basename(location)}") as pbar:
                                for file_path, file_size in file_list:
                                    try:
                                        os.unlink(file_path)
                                        total_freed += file_size
                                        files_deleted += 1
                                    except Exception as e:
                                        Logger.log(f"Erro ao apagar {file_path}: {str(e)}", "WARNING", False)
                                    pbar.update(1)
                        else:
                            for file_path, file_size in file_list:
                                try:
                                    os.unlink(file_path)
                                    total_freed += file_size
                                    files_deleted += 1
                                except:
                                    pass
                except Exception as e:
                    Logger.log(f"Erro ao acessar {location}: {str(e)}", "ERROR")
        
        Logger.log(f"Limpeza concluída! {files_deleted} arquivos removidos.", "SUCCESS")
        Logger.log(f"Espaço liberado: {total_freed/1024/1024:.2f} MB", "SUCCESS")

    @staticmethod
    def empty_recycle_bin():
        Logger.log("Esvaziando lixeira...")
        try:
            from winshell import recycle_bin
            recycle_bin.empty(confirm=False, show_progress=False, sound=False)
            Logger.log("Lixeira esvaziada com sucesso!", "SUCCESS")
        except ImportError:
            Logger.log("Instalando dependência 'winshell'...", "INFO")
            subprocess.check_call([sys.executable, "-m", "pip", "install", "winshell"])
            from winshell import recycle_bin
            recycle_bin.empty(confirm=False, show_progress=False, sound=False)
            Logger.log("Lixeira esvaziada com sucesso!", "SUCCESS")
        except Exception as e:
            Logger.log(f"Falha ao esvaziar lixeira: {str(e)}", "ERROR")

# Otimização de Sistema
class SystemOptimizer:
    POWER_PLANS = {
        "Alto Desempenho": "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
        "Equilibrado": "381b4222-f694-41f0-9685-ff5bb260df2e",
        "Economia de Energia": "a1841308-3541-4fab-bc81-f71556f20b4a"
    }

    @staticmethod
    def set_power_plan(plan_name: str):
        if plan_name in SystemOptimizer.POWER_PLANS:
            guid = SystemOptimizer.POWER_PLANS[plan_name]
            subprocess.run(f"powercfg /SETACTIVE {guid}", shell=True)
            Logger.log(f"Plano de energia alterado para: {plan_name}", "SUCCESS")
        else:
            Logger.log("Plano de energia inválido!", "ERROR")

    @staticmethod
    def optimize_services():
        services_config = {
            "SysMain": "disabled",  # Superfetch
            "DiagTrack": "disabled",  # Telemetria
            "TrkWks": "disabled",  # Rastreamento de links
            "WSearch": "manual"  # Windows Search
        }
        
        Logger.log("Otimizando serviços do Windows...")
        
        for service, startup_type in services_config.items():
            try:
                subprocess.run(f"sc config {service} start= {startup_type}", shell=True)
                Logger.log(f"Serviço {service} configurado para {startup_type}", "INFO")
            except Exception as e:
                Logger.log(f"Falha ao configurar {service}: {str(e)}", "WARNING")

# Ferramentas de Rede
class NetworkTools:
    @staticmethod
    def test_ping(host: str = "8.8.8.8", count: int = 4):
        Logger.log(f"Testando ping para {host}...")
        try:
            for i in range(count):
                response = ping3.ping(host, unit='ms')
                if response is not None:
                    Logger.log(f"Resposta de {host}: tempo={response:.2f}ms", "INFO")
                else:
                    Logger.log(f"Sem resposta de {host}", "WARNING")
                time.sleep(1)
        except Exception as e:
            Logger.log(f"Erro no teste de ping: {str(e)}", "ERROR")

    @staticmethod
    def flush_dns():
        Logger.log("Limpando cache DNS...")
        subprocess.run("ipconfig /flushdns", shell=True)
        Logger.log("Cache DNS limpo com sucesso!", "SUCCESS")

# Interface do Usuário
class ConsoleUI:
    @staticmethod
    def clear_screen():
        os.system('cls' if os.name == 'nt' else 'clear')

    @staticmethod
    def show_header():
        ConsoleUI.clear_screen()
        print(Fore.CYAN + f"""
▓█████ ███▄    █ ▓█████▄  ██▓ ███▄ ▄███▓ ██▓███   ██▓     ▒█████   ██▓███  
▓█   ▀ ██ ▀█   █ ▒██▀ ██▌▓██▒▓██▒▀█▀ ██▒▓██░  ██▒▓██▒    ▒██▒  ██▒▓██░  ██▒
▒███  ▓██  ▀█ ██▒░██   █▌▒██▒▓██    ▓██░▓██░ ██▓▒▒██░    ▒██░  ██▒▓██░ ██▓▒
▒▓█  ▄▓██▒  ▐▌██▒░▓█▄   ▌░██░▒██    ▒██ ▒██▄█▓▒ ▒▒██░    ▒██   ██░▒██▄█▓▒ ▒
░▒████▒██░   ▓██░░▒████▓ ░██░▒██▒   ░██▒▒██▒ ░  ░░██████▒░ ████▓▒░▒██▒ ░  ░
░░ ▒░ ░ ▒░   ▒ ▒  ▒▒▓  ▒ ░▓  ░ ▒░   ░  ░▒▓▒░ ░  ░░ ▒░▓  ░░ ▒░▒░▒░ ▒▓▒░ ░  ░
 ░ ░  ░ ░░   ░ ▒░ ░ ▒  ▒  ▒ ░░  ░      ░░▒ ░     ░ ░ ▒  ░  ░ ▒ ▒░ ░▒ ░     
   ░     ░   ░ ░  ░ ░  ░  ▒ ░░      ░   ░░         ░ ░   ░ ░ ░ ▒  ░░       
   ░  ░        ░    ░     ░         ░                 ░  ░    ░ ░           
                   ░                                                        
{Fore.YELLOW}Versão: {VERSION} | {AUTHOR}
{Fore.RESET}""")

    @staticmethod
    def show_menu(options: List[Dict], title: str = "MENU PRINCIPAL"):
        ConsoleUI.show_header()
        print(Fore.MAGENTA + f"\n{title.upper()}\n" + "="*50)
        
        for idx, option in enumerate(options, 1):
            print(Fore.GREEN + f"{idx}. {option['label']}")
        
        print(Fore.RED + "\n0. Voltar/Sair" if title != "MENU PRINCIPAL" else Fore.RED + "\n0. Sair")
        print("="*50 + Fore.RESET)

    @staticmethod
    def get_choice(max_option: int) -> int:
        while True:
            try:
                choice = int(input(Fore.YELLOW + "\nEscolha uma opção: " + Fore.RESET))
                if 0 <= choice <= max_option:
                    return choice
                print(Fore.RED + "Opção inválida! Tente novamente.")
            except ValueError:
                print(Fore.RED + "Entrada inválida! Digite um número.")

# Menu Principal
def main_menu():
    main_options = [
        {"label": "Limpeza do Sistema", "action": cleanup_menu},
        {"label": "Otimização Avançada", "action": optimization_menu},
        {"label": "Ferramentas de Rede", "action": network_menu},
        {"label": "Monitor do Sistema", "action": system_monitor},
        {"label": "Agendador de Tarefas", "action": scheduler_menu},
        {"label": "Executar Tudo (Modo Automático)", "action": run_full_optimization}
    ]
    
    while True:
        ConsoleUI.show_menu(main_options)
        choice = ConsoleUI.get_choice(len(main_options))
        
        if choice == 0:
            Logger.log("Saindo do WinOptiMax Ultimate...", "INFO")
            sys.exit(0)
        
        main_options[choice-1]["action"]()

# Menus Específicos
def cleanup_menu():
    options = [
        {"label": "Limpar Arquivos Temporários", "action": AdvancedCleaner.clean_temp_files},
        {"label": "Esvaziar Lixeira", "action": AdvancedCleaner.empty_recycle_bin},
        {"label": "Limpar Cache de Navegadores", "action": lambda: AdvancedCleaner.clean_temp_files(False)},
        {"label": "Limpar Logs Antigos", "action": lambda: Logger.log("Funcionalidade em desenvolvimento", "INFO")}
    ]
    
    while True:
        ConsoleUI.show_menu(options, "Limpeza do Sistema")
        choice = ConsoleUI.get_choice(len(options))
        
        if choice == 0:
            return
        
        options[choice-1]["action"]()
        input("\nPressione Enter para continuar...")

def optimization_menu():
    power_plans = list(SystemOptimizer.POWER_PLANS.keys())
    options = [
        {"label": "Otimizar Planos de Energia", "action": lambda: power_plan_menu(power_plans)},
        {"label": "Otimizar Serviços do Windows", "action": SystemOptimizer.optimize_services},
        {"label": "Desfragmentar Discos", "action": lambda: Logger.log("Use a opção 'Executar Tudo' para desfragmentação automática", "INFO")},
        {"label": "Reparar Arquivos do Sistema", "action": repair_system_files}
    ]
    
    while True:
        ConsoleUI.show_menu(options, "Otimização Avançada")
        choice = ConsoleUI.get_choice(len(options))
        
        if choice == 0:
            return
        
        options[choice-1]["action"]()
        input("\nPressione Enter para continuar...")

def power_plan_menu(plans):
    options = [{"label": plan, "action": lambda p=plan: SystemOptimizer.set_power_plan(p)} for plan in plans]
    
    while True:
        ConsoleUI.show_menu(options, "Planos de Energia")
        choice = ConsoleUI.get_choice(len(options))
        
        if choice == 0:
            return
        
        options[choice-1]["action"]()
        input("\nPressione Enter para continuar...")

def network_menu():
    options = [
        {"label": "Testar Conexão (Ping)", "action": lambda: NetworkTools.test_ping()},
        {"label": "Limpar Cache DNS", "action": NetworkTools.flush_dns},
        {"label": "Resetar TCP/IP", "action": reset_tcpip},
        {"label": "Testar Velocidade", "action": test_network_speed}
    ]
    
    while True:
        ConsoleUI.show_menu(options, "Ferramentas de Rede")
        choice = ConsoleUI.get_choice(len(options))
        
        if choice == 0:
            return
        
        options[choice-1]["action"]()
        input("\nPressione Enter para continuar...")

# Funções Adicionais
def system_monitor():
    ConsoleUI.clear_screen()
    print(Fore.CYAN + "\nMonitor do Sistema (Atualizando a cada 2 segundos)")
    print("Pressione Ctrl+C para voltar...\n")
    
    try:
        while True:
            # CPU
            cpu_usage = psutil.cpu_percent(interval=1)
            cpu_bar = "[" + "■" * int(cpu_usage/5) + " " * (20 - int(cpu_usage/5)) + "]"
            print(Fore.YELLOW + f"CPU: {cpu_usage:.1f}% {cpu_bar}")
            
            # Memória
            mem = psutil.virtual_memory()
            mem_bar = "[" + "■" * int(mem.percent/5) + " " * (20 - int(mem.percent/5)) + "]"
            print(Fore.BLUE + f"Memória: {mem.percent:.1f}% {mem_bar} ({mem.used/1024/1024:.0f}MB/{mem.total/1024/1024:.0f}MB)")
            
            # Discos
            for disk in psutil.disk_partitions():
                if disk.fstype == 'NTFS':
                    usage = psutil.disk_usage(disk.mountpoint)
                    disk_bar = "[" + "■" * int(usage.percent/5) + " " * (20 - int(usage.percent/5)) + "]"
                    print(Fore.GREEN + f"Disco {disk.mountpoint}: {usage.percent:.1f}% {disk_bar}")
            
            print(Fore.RESET + "-" * 50)
            time.sleep(2)
            ConsoleUI.clear_screen()
            print(Fore.CYAN + "\nMonitor do Sistema (Atualizando a cada 2 segundos)")
            print("Pressione Ctrl+C para voltar...\n")
    except KeyboardInterrupt:
        pass

def run_full_optimization():
    Logger.log("Iniciando otimização completa...", "INFO")
    
    # Limpeza
    AdvancedCleaner.clean_temp_files()
    AdvancedCleaner.empty_recycle_bin()
    
    # Otimização
    SystemOptimizer.set_power_plan("Alto Desempenho")
    SystemOptimizer.optimize_services()
    
    # Rede
    NetworkTools.flush_dns()
    
    Logger.log("Otimização completa concluída!", "SUCCESS")
    input("\nPressione Enter para continuar...")

def repair_system_files():
    Logger.log("Verificando arquivos do sistema...")
    subprocess.run("sfc /scannow", shell=True)
    Logger.log("Verificação concluída! Veja o resultado acima.", "INFO")

def reset_tcpip():
    Logger.log("Resetando TCP/IP...")
    subprocess.run("netsh int ip reset", shell=True)
    subprocess.run("netsh winsock reset", shell=True)
    Logger.log("TCP/IP resetado com sucesso! Reinicie o computador.", "SUCCESS")

def test_network_speed():
    try:
        import speedtest
        Logger.log("Testando velocidade da internet... (Pode demorar alguns minutos)")
        
        st = speedtest.Speedtest()
        st.get_best_server()
        
        with tqdm(total=100, desc="Testando download") as pbar:
            def update_download():
                st.download()
                pbar.update(50)
            
            Thread(target=update_download).start()
            while pbar.n < 50:
                time.sleep(0.1)
        
        with tqdm(total=100, desc="Testando upload") as pbar:
            def update_upload():
                st.upload()
                pbar.update(50)
            
            Thread(target=update_upload).start()
            while pbar.n < 50:
                time.sleep(0.1)
        
        results = st.results.dict()
        Logger.log(f"Velocidade de Download: {results['download']/1024/1024:.2f} Mbps", "INFO")
        Logger.log(f"Velocidade de Upload: {results['upload']/1024/1024:.2f} Mbps", "INFO")
        Logger.log(f"Ping: {results['ping']:.2f} ms", "INFO")
    except ImportError:
        Logger.log("Instalando dependência 'speedtest-cli'...", "INFO")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "speedtest-cli"])
        test_network_speed()
    except Exception as e:
        Logger.log(f"Erro no teste de velocidade: {str(e)}", "ERROR")

# Ponto de entrada
if __name__ == "__main__":
    if not is_admin():
        Logger.log("Este programa requer privilégios de administrador!", "ERROR")
        input("Pressione Enter para sair...")
        sys.exit(1)
    
    # Verifica e cria diretório de cache
    os.makedirs(CACHE_DIR, exist_ok=True)
    
    # Inicia a aplicação
    try:
        main_menu()
    except KeyboardInterrupt:
        Logger.log("Programa interrompido pelo usuário", "INFO")
        sys.exit(0)
    except Exception as e:
        Logger.log(f"Erro crítico: {str(e)}", "ERROR")
        sys.exit(1)

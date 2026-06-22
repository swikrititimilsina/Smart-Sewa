# run_chatbot.py
from chatbot.smart_sathi import SmartSathi

def print_line():
    print("\n" + "─" * 56 + "\n")

def print_welcome():
    print("╔════════════════════════════════════════════════════════╗")
    print("║              SMART SATHI CHATBOT                       ║")
    print("║      Bilingual: English + Nepali (नेपाली)               ║")
    print("╠════════════════════════════════════════════════════════╣")
    print("║  Commands: history | reset | exit                      ║")
    print("╚════════════════════════════════════════════════════════╝")
    print()

def main():
    print_welcome()
    bot = SmartSathi()
    print(f"Smart Sathi: {bot.respond('hello')}")
    print_line()

    while True:
        try:
            user_input = input("You: ").strip()
        except KeyboardInterrupt:
            print("\n\nSmart Sathi: Goodbye! Namaste!")
            break

        if user_input.lower() == "exit":
            print(f"\nSmart Sathi: {bot.respond('bye')}")
            break
        elif user_input.lower() == "history":
            history = bot.get_history()
            if not history:
                print("\n[No history yet]\n")
            else:
                print("\nConversation History:")
                for h in history:
                    print(f"  Turn {h['turn']} [{h['language']}]:")
                    print(f"    You    : {h['user']}")
                    print(f"    Intent : {h['intent_type']} → {h['intent_value']}")
            print_line()
            continue
        elif user_input.lower() == "reset":
            bot.reset()
            print("\n[Conversation reset!]\n")
            print(f"Smart Sathi: {bot.respond('hello')}")
            print_line()
            continue
        elif not user_input:
            continue

        response = bot.respond(user_input)
        print(f"\nSmart Sathi: {response}")
        print_line()

if __name__ == "__main__":
    main()
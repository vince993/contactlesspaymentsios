import SwiftUI

struct Payment: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let amount: Double
    let icon: String
}

struct ContentView: View {
    @State private var balance = 4286.40
    @State private var selectedTab = 0
    @State private var showingPayment = false
    @State private var selectedPayment: Payment?
    @State private var payments = [
        Payment(title: "青禾咖啡", subtitle: "今天 14:26 · 非接触支付", amount: -36, icon: "cup.and.saucer.fill"),
        Payment(title: "城市交通", subtitle: "今天 09:12 · 手机钱包", amount: -4, icon: "tram.fill"),
        Payment(title: "好友转入", subtitle: "昨天 20:45 · 即时到账", amount: 268, icon: "arrow.down.left")
    ]

    private let teal = Color(red: 0.03, green: 0.50, blue: 0.45)
    private let ink = Color(red: 0.08, green: 0.15, blue: 0.13)

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { dashboard }
                .tabItem { Label("首页", systemImage: "house.fill") }.tag(0)
            NavigationStack { activityPage }
                .tabItem { Label("活动", systemImage: "list.bullet.rectangle") }.tag(1)
            Color.clear
                .tabItem { Label("付款", systemImage: "wave.3.right.circle.fill") }.tag(2)
            NavigationStack { profilePage }
                .tabItem { Label("我的", systemImage: "person.crop.circle") }.tag(3)
        }
        .tint(teal)
        .onChange(of: selectedTab) { tab in
            if tab == 2 { showingPayment = true; selectedTab = 0 }
        }
        .sheet(isPresented: $showingPayment) {
            PaymentSheet(balance: balance) { amount in
                balance -= amount
                let time = Date().formatted(date: .omitted, time: .shortened)
                payments.insert(Payment(title: "非接触付款", subtitle: "今天 \(time) · PulsePay", amount: -amount, icon: "wave.3.right"), at: 0)
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $selectedPayment) { payment in
            TransactionDetail(payment: payment, teal: teal)
                .presentationDetents([.medium])
        }
    }

    private var dashboard: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("PulsePay").font(.title2.bold()).foregroundStyle(ink)
                        Text("下午好，何先生").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "bell.fill").foregroundStyle(teal).frame(width: 44, height: 44).background(.white, in: Circle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("可用余额").font(.subheadline).foregroundStyle(.white.opacity(0.78))
                    Text(balance, format: .currency(code: "CNY")).font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    Spacer().frame(height: 18)
                    HStack { Text("VISA  ••••  0824").font(.subheadline.bold()); Spacer(); Image(systemName: "wave.3.right") }
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                .padding(20)
                .background(LinearGradient(colors: [teal, Color(red: 0.08, green: 0.34, blue: 0.38)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 12))

                HStack {
                    ActionButton(icon: "wave.3.right", title: "轻触付款", color: teal) { showingPayment = true }
                    ActionButton(icon: "arrow.up.right", title: "转账", color: teal) { }
                    ActionButton(icon: "qrcode", title: "收款码", color: teal) { }
                    ActionButton(icon: "ellipsis", title: "更多", color: teal) { }
                }

                HStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill").foregroundStyle(teal)
                    Text("NFC 安全支付已开启").font(.subheadline.bold())
                    Spacer()
                    Text("设备就绪").font(.caption).foregroundStyle(teal)
                }
                .padding(15).background(teal.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))

                HStack { Text("最近活动").font(.headline); Spacer(); Button("查看全部") { selectedTab = 1 }.font(.caption.bold()).foregroundStyle(teal) }
                VStack(spacing: 1) {
                    ForEach(payments.prefix(3)) { payment in
                        TransactionRow(payment: payment, teal: teal).onTapGesture { selectedPayment = payment }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("随时管理每笔消费").font(.subheadline.bold())
                        Text("官方 iPhone 客户端").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image("apple").resizable().scaledToFit().frame(width: 140, height: 49).accessibilityLabel("Download on the App Store")
                }
                .padding(15).background(.white, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(20)
        }
        .background(Color(red: 0.96, green: 0.97, blue: 0.97))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var activityPage: some View {
        List(payments) { payment in
            TransactionRow(payment: payment, teal: teal).listRowInsets(EdgeInsets()).onTapGesture { selectedPayment = payment }
        }.navigationTitle("全部活动")
    }

    private var profilePage: some View {
        List {
            Section { Label("何先生", systemImage: "person.crop.circle.fill"); Label("支付方式", systemImage: "creditcard.fill"); Label("安全与隐私", systemImage: "lock.shield.fill") }
            Section { Label("帮助中心", systemImage: "questionmark.circle") }
        }.navigationTitle("我的")
    }
}

struct ActionButton: View {
    let icon: String, title: String, color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) { VStack(spacing: 7) { Image(systemName: icon).font(.title3).frame(width: 48, height: 48).background(.white, in: Circle()); Text(title).font(.caption2.bold()).lineLimit(1) }.foregroundStyle(color).frame(maxWidth: .infinity) }
    }
}

struct TransactionRow: View {
    let payment: Payment, teal: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: payment.icon).foregroundStyle(payment.amount > 0 ? teal : .primary).frame(width: 42, height: 42).background(Color.gray.opacity(0.10), in: Circle())
            VStack(alignment: .leading, spacing: 3) { Text(payment.title).font(.subheadline.bold()); Text(payment.subtitle).font(.caption).foregroundStyle(.secondary) }
            Spacer()
            Text(payment.amount, format: .currency(code: "CNY")).font(.subheadline.bold()).foregroundStyle(payment.amount > 0 ? teal : .primary)
        }.padding(14).background(.white)
    }
}

struct PaymentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let balance: Double
    let onComplete: (Double) -> Void
    @State private var amount = ""
    @State private var step = 0
    @State private var error = ""
    private let teal = Color(red: 0.03, green: 0.50, blue: 0.45)

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: step == 0 ? "wave.3.right.circle.fill" : "checkmark.circle.fill").font(.system(size: 54)).foregroundStyle(teal)
                Text(step == 0 ? "轻触付款" : "付款成功").font(.title2.bold())
                if step == 0 {
                    TextField("0.00", text: $amount).keyboardType(.decimalPad).font(.system(size: 34, weight: .bold)).multilineTextAlignment(.center)
                    Text(error.isEmpty ? "输入金额后，将手机靠近支持非接触支付的终端" : error).font(.caption).foregroundStyle(error.isEmpty ? .secondary : .red).multilineTextAlignment(.center)
                    Button("模拟付款") {
                        guard let value = Double(amount), value > 0, value <= balance else { error = "请输入有效且不超过余额的金额"; return }
                        onComplete(value); step = 1
                    }.buttonStyle(.borderedProminent).tint(teal).controlSize(.large)
                } else {
                    Text((Double(amount) ?? 0), format: .currency(code: "CNY")).font(.title.bold())
                    Button("完成") { dismiss() }.buttonStyle(.borderedProminent).tint(teal)
                }
                Spacer()
            }.padding(28).navigationTitle("安全支付演示").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("关闭") { dismiss() } } }
        }
    }
}

struct TransactionDetail: View {
    @Environment(\.dismiss) private var dismiss
    let payment: Payment, teal: Color
    var body: some View {
        NavigationStack { VStack(spacing: 18) { Image(systemName: "checkmark.circle.fill").font(.system(size: 50)).foregroundStyle(teal); Text(payment.title).font(.title2.bold()); Text(payment.amount, format: .currency(code: "CNY")).font(.title.bold()); Text(payment.subtitle).foregroundStyle(.secondary); Label("交易已完成", systemImage: "checkmark.shield").font(.subheadline); Spacer() }.padding(28).navigationTitle("交易详情").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("关闭") { dismiss() } } } }
    }
}

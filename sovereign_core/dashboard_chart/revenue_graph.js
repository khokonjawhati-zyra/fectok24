// # 4. Dashboard Live Revenue Chart Logic (Sovereign Analytics)
// Real-time graph update logic [cite: 2026-01-08]
function updateLiveRevenueChart(newRevenue) {
    const timeStamp = new Date().toLocaleTimeString();
    chartData.push({ time: timeStamp, amount: newRevenue });
    renderGraph(); // Graph rises as revenue increases
    console.log("📈 Chart Updated: \$" + newRevenue + " added to USD Stream.");
}

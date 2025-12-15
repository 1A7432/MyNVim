#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <cmath>
#include <map>
#include <set>
#include <queue>
#include <stack>
#include <deque>
using namespace std;

// 类型简写
using ll = long long;
using ull = unsigned long long;
using pii = pair<int, int>;
using pll = pair<ll, ll>;
using vi = vector<int>;
using vll = vector<ll>;

// 常用宏定义
#define FOR(i, a, b) for(int i = (a); i < (b); ++i)
#define RFOR(i, a, b) for(int i = (a); i > (b); --i)
#define all(x) (x).begin(), (x).end()
#define sz(x) ((int)(x).size())
#define pb push_back
#define mp make_pair
#define fi first
#define se second

// 调试宏
#ifdef LOCAL
#define debug(x) cerr << #x << " = " << (x) << endl
#define debugv(v) cerr << #v << " = "; for(auto x : v) cerr << x << " "; cerr << endl
#else
#define debug(x)
#define debugv(v)
#endif

// 常量
const int INF = 0x3f3f3f3f;
const ll LLINF = 0x3f3f3f3f3f3f3f3fLL;
const double EPS = 1e-9;
const int MOD = 1e9 + 7;

// 快速幂
ll qpow(ll a, ll b, ll mod = MOD) {
    ll res = 1;
    while(b) {
        if(b & 1) res = res * a % mod;
        a = a * a % mod;
        b >>= 1;
    }
    return res;
}

// GCD
ll gcd(ll a, ll b) {
    return b ? gcd(b, a % b) : a;
}

// 解题函数
void solve() {
    // 在这里编写解题代码

}

int main() {
    // 加速输入输出
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    cout.tie(nullptr);

    int t = 1;
    // cin >> t;  // 多测试用例时取消注释

    while(t--) {
        solve();
    }

    return 0;
}

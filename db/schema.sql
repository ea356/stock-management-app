-- ============================================================
-- Stock management app: テーブル作成 + サンプルデータ投入
-- データベース: stock-management-app
--
-- 実行例（プロジェクトのルートで）:
--   createdb stock-management-app
--   psql -v ON_ERROR_STOP=1 stock-management-app -f db/schema.sql
-- ============================================================


-- ------------------------------------------------------------
-- 1. テーブル作成
--    外部キーで参照される側（inventory）を先に作成する
-- ------------------------------------------------------------

-- 在庫管理表
CREATE TABLE inventory (
    id             SERIAL       PRIMARY KEY,
    item_code      VARCHAR(50)  NOT NULL UNIQUE,                               -- アイテムコード（変更不可）
    item_name      VARCHAR(255) NOT NULL,                                      -- アイテム名
    unit_price     INTEGER      NOT NULL CHECK (unit_price >= 0),              -- 単価
    stock_quantity INTEGER      NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0) -- 在庫数
);

-- 入出荷管理表（inventory.item_code を参照）
CREATE TABLE stock_transactions (
    id        SERIAL      PRIMARY KEY,
    date      DATE        NOT NULL,                                                      -- 日付
    type1     VARCHAR(10) NOT NULL CHECK (type1 IN ('入荷', '出荷')),                     -- 種別1
    type2     VARCHAR(10) NOT NULL CHECK (type2 IN ('発送先', '発送元')),                 -- 種別2
    type3     VARCHAR(20) NOT NULL CHECK (type3 IN ('販売', '貸出返却', 'サンプル使用')), -- 種別3
    item_code VARCHAR(50) NOT NULL,                                                      -- アイテムコード
    quantity  INTEGER     NOT NULL CHECK (quantity > 0),                                 -- 数量
    CONSTRAINT fk_stock_transactions_item_code
        FOREIGN KEY (item_code) REFERENCES inventory (item_code)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);


-- ------------------------------------------------------------
-- 2. サンプルデータ投入
--    在庫数は「入荷数 - 出荷数」と一致するように設定
-- ------------------------------------------------------------

BEGIN;

-- アイテム 5件
INSERT INTO inventory (item_code, item_name, unit_price, stock_quantity) VALUES
    ('A-001', 'ボールペン',     120, 50),  -- 入荷100 - 出荷50
    ('A-002', 'ノート',         200, 40),  -- 入荷50  - 出荷10
    ('A-003', '消しゴム',        80, 55),  -- 入荷80  - 出荷25
    ('A-004', 'クリアファイル', 150, 60),  -- 入荷60  - 出荷0
    ('A-005', '付箋',           250, 25);  -- 入荷40  - 出荷15

-- 入荷 5件
INSERT INTO stock_transactions (date, type1, type2, type3, item_code, quantity) VALUES
    ('2026-11-01', '入荷', '発送元', '販売', 'A-001', 100),
    ('2026-11-01', '入荷', '発送元', '販売', 'A-002',  50),
    ('2026-11-02', '入荷', '発送元', '販売', 'A-003',  80),
    ('2026-11-03', '入荷', '発送元', '販売', 'A-004',  60),
    ('2026-11-04', '入荷', '発送元', '販売', 'A-005',  40);

-- 出荷 5件
INSERT INTO stock_transactions (date, type1, type2, type3, item_code, quantity) VALUES
    ('2026-11-05', '出荷', '発送先', '販売',         'A-001', 30),
    ('2026-11-06', '出荷', '発送先', 'サンプル使用', 'A-002', 10),
    ('2026-11-07', '出荷', '発送先', '販売',         'A-003', 25),
    ('2026-11-08', '出荷', '発送先', '貸出返却',     'A-005', 15),
    ('2026-11-09', '出荷', '発送先', '販売',         'A-001', 20);

COMMIT;

import streamlit as st
import base64
import datetime
import os
import json
from openai import OpenAI

# --- 1. 初始化配置与持久化存储 ---
st.set_page_config(page_title="MIMO TTS 导演全功能版", layout="wide")

VOICE_DB_FILE = "mimo_voices_library.json"

def load_voice_library():
    if os.path.exists(VOICE_DB_FILE):
        try:
            with open(VOICE_DB_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except:
            return {}
    return {}

def save_to_library(name, b64_data, mime_type):
    lib = load_voice_library()
    lib[name] = {
        "data": b64_data,
        "mime": mime_type,
        "date": datetime.datetime.now().strftime("%Y-%m-%d")
    }
    with open(VOICE_DB_FILE, "w", encoding="utf-8") as f:
        json.dump(lib, f, ensure_ascii=False, indent=4)

# --- 2. 侧边栏设置 ---
with st.sidebar:
    st.title("🔐 系统设置")
    mimo_api_key = st.sidebar.text_input("MIMO API KEY", type="password")
    base_url = st.sidebar.text_input("API Base URL", value="https://api.xiaomimimo.com/v1")
    
    st.divider()
    st.markdown("### 📜 已存音色管理")
    lib = load_voice_library()
    if lib:
        for name in list(lib.keys()):
            col_n, col_d = st.columns([3, 1])
            col_n.caption(f"👤 {name}")
            if col_d.button("🗑️", key=f"side_del_{name}"):
                del lib[name]
                with open(VOICE_DB_FILE, "w", encoding="utf-8") as f:
                    json.dump(lib, f, ensure_ascii=False, indent=4)
                st.rerun()
    else:
        st.info("音色库暂无数据")

if not mimo_api_key:
    st.title("🎙️ MIMO 语音合成工作站")
    st.info("💡 请在左侧边栏输入 API Key 以激活。")
    st.stop()

client = OpenAI(api_key=mimo_api_key, base_url=base_url)

# --- 3. 核心合成逻辑 ---
def run_synthesis(model, user_msg, assistant_msg, voice_id_or_uri):
    try:
        with st.spinner("🎬 正在合成音频..."):
            res = client.chat.completions.create(
                model=model,
                messages=[
                    {"role": "user", "content": user_msg},
                    {"role": "assistant", "content": assistant_msg}
                ],
                audio={"format": "wav", "voice": voice_id_or_uri}
            )
            audio_bytes = base64.b64decode(res.choices[0].message.audio.data)
            st.audio(audio_bytes, format="audio/wav")
            
            fn = f"MIMO_{datetime.datetime.now().strftime('%H%M%S')}.wav"
            st.download_button("💾 下载成品音频", audio_bytes, file_name=fn, mime="audio/wav")
    except Exception as e:
        st.error(f"❌ 合成失败: {str(e)}")

# --- 4. 主界面布局 ---
st.title("🎙️ MIMO 导演级语音工作站")

tab1, tab2, tab3 = st.tabs(["🎭 导演模式", "🏷️ 标签控制", "🧬 音色克隆与库"])

# 获取最新音色库用于下拉菜单
v_lib = load_voice_library()
saved_voice_names = list(v_lib.keys())

# --- TAB 1: 导演模式 ---
with tab1:
    col1, col2 = st.columns([1, 1])
    with col1:
        st.subheader("🎬 剧本设定")
        d_role = st.text_area("角色设定", "冷艳的御姐，说话带着一丝慵懒...", key="d_r")
        d_scene = st.text_area("场景描述", "深夜的酒吧吧台...", key="d_s")
        d_guide = st.text_area("演出指导", "语速慢，重音放在末尾...", key="d_g")
        full_user = f"角色：{d_role}\n场景：{d_scene}\n指导：{d_guide}"
    with col2:
        st.subheader("📄 台词")
        v_choice_1 = st.selectbox("选择声线", ["Chloe", "Alloy", "Echo", "Fable"] + saved_voice_names, key="v1")
        d_text = st.text_area("台词内容", "这杯酒，算我请你的。", height=150, key="t1")
        
        if st.button("🚀 导演模式合成", use_container_width=True):
            model = "mimo-v2.5-tts" if v_choice_1 in ["Chloe", "Alloy", "Echo", "Fable"] else "mimo-v2.5-tts-voiceclone"
            v_input = v_choice_1.lower() if v_choice_1 in ["Chloe", "Alloy", "Echo", "Fable"] else f"data:{v_lib[v_choice_1]['mime']};base64,{v_lib[v_choice_1]['data']}"
            run_synthesis(model, full_user, d_text, v_input)

# --- TAB 2: 标签控制 ---
with tab2:
    st.subheader("🏷️ 精细标签调节")
    tag_u = st.text_input("整体风格描述", "充满活力的宣传片口吻")
    tag_a = st.text_area("带标签文本", "(磁性) 欢迎来到 [吸气] 未来世界！", height=150)
    v_choice_2 = st.selectbox("选择声线", ["Chloe", "Alloy", "Echo", "Fable"] + saved_voice_names, key="v2")
    
    if st.button("🔥 标签合成", use_container_width=True):
        model = "mimo-v2.5-tts" if v_choice_2 in ["Chloe", "Alloy", "Echo", "Fable"] else "mimo-v2.5-tts-voiceclone"
        v_input = v_choice_2.lower() if v_choice_2 in ["Chloe", "Alloy", "Echo", "Fable"] else f"data:{v_lib[v_choice_2]['mime']};base64,{v_lib[v_choice_2]['data']}"
        run_synthesis(model, tag_u, tag_a, v_input)

# --- TAB 3: 音色克隆与库 (找回便捷克隆) ---
with tab3:
    col_left, col_right = st.columns([1, 1])
    
    with col_left:
        st.subheader("⚡ 即时克隆 (不保存)")
        st.caption("直接上传音频并合成，适合一次性任务")
        quick_file = st.file_uploader("上传参考音频", type=["wav", "mp3"], key="quick_up")
        quick_text = st.text_area("合成文本", "你好，这是即时复刻的测试。", key="quick_t")
        
        if st.button("🪄 即时复刻合成", use_container_width=True) and quick_file:
            mime = quick_file.type
            b64 = base64.b64encode(quick_file.read()).decode("utf-8")
            uri = f"data:{mime};base64,{b64}"
            run_synthesis("mimo-v2.5-tts-voiceclone", "复刻音色", quick_text, uri)

    with col_right:
        st.subheader("💾 音色入库 (永久保存)")
        st.caption("保存后，在上方各选项卡的下拉菜单中直接调用")
        new_file = st.file_uploader("上传音频到库", type=["wav", "mp3"], key="lib_up")
        new_name = st.text_input("音色命名")
        if st.button("📥 存入音色库", use_container_width=True) and new_file and new_name:
            b64_str = base64.b64encode(new_file.read()).decode("utf-8")
            save_to_library(new_name, b64_str, new_file.type)
            st.success(f"'{new_name}' 已保存！")
            st.rerun()

st.divider()
st.caption("MIMO TTS 导演版 | 结合了即时克隆的便捷与音色库的持久")

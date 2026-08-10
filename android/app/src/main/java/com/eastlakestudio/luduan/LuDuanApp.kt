package com.eastlakestudio.luduan

import android.app.Application

class LuDuanApp : Application() {
    val repository by lazy { com.eastlakestudio.luduan.data.GameRepository.get(this) }
}
